##################################################################################################
#####Some insipration taken from https://github.com/instructure/dockerfiles ######################
##################################################################################################
##################################################################################################
##### Base docker container ######################################################################
FROM ruby:2.6-alpine as base

# Set app home
ENV APP_HOME /usr/src/app/
WORKDIR $APP_HOME

# Create a 'docker' user
# Which will be used to run the app as an unprivileged user
RUN  addgroup -g 9999 -S docker && \
     adduser -u 9999 -G docker -S -D -g "Docker User" docker && \
     mkdir -p /usr/src/run $APP_HOME && \
     chown -R docker:docker /usr/src $APP_HOME

# Install base packages
RUN apk add --no-cache tzdata tini sudo runit

# Helpfull little script, when using docker-compose in development
COPY build/wait-for /usr/local/bin/wait-for

# Default entrypoint using tini
ENTRYPOINT ["/sbin/tini", "--"]

##### Nginx container ############################################################################
FROM base as nginx

# Install packages and configuration
# Send nginx logs to stdout, and give docker user permission to start nginx
RUN apk add --no-cache nginx && \
    rm -rf /etc/nginx/conf.d/default.conf && \
    chown -R docker:docker /var/lib/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stdout /var/log/nginx/error.log && \
    echo 'docker ALL=(ALL) NOPASSWD: SETENV: /usr/sbin/nginx' >> /etc/sudoers

COPY --chown=docker:docker build/nginx-entrypoint /usr/local/bin/entrypoint
COPY --chown=docker:docker build/nginx.conf /etc/nginx/nginx.conf

USER docker

EXPOSE 80
CMD [ "/usr/local/bin/entrypoint" ]

##### Install build deps, and build gems for app##########################################################
FROM base as gem-builder
RUN apk --update add build-base ruby-dev openssl-dev libxml2-dev libxslt-dev mysql-dev


##### Build gems for the ruby-server #####################################################################
FROM gem-builder as ruby-server-gems
COPY ruby-server/Gemfile* $APP_HOME
RUN bundle install --jobs=8

##### Build gems for the web-app
FROM gem-builder as web-app-gems
COPY web/Gemfile* $APP_HOME
RUN bundle install --jobs=8

##### Build gems for the web-app
FROM gem-builder as ext-server-gems
COPY extensions/Gemfile* $APP_HOME
RUN bundle install --jobs=8

##### Ruby Standardfile Server container ######################################################
FROM base as ruby-server

# Install additional packages
RUN apk add --no-cache mariadb-client mariadb-dev

# copy over gems and application
COPY --from=ruby-server-gems --chown=docker:docker /usr/local/bundle /usr/local/bundle
COPY --chown=docker:docker ruby-server/ $APP_HOME
COPY --chown=docker:docker build/ruby-server-entrypoint /usr/local/bin/entrypoint

USER docker
RUN bundle exec rake assets:precompile

EXPOSE 3000
CMD [ "/usr/local/bin/entrypoint", "start" ]

##### Web app container #######################################################################
FROM base as web-app

# Install additional packages
RUN apk add --no-cache nodejs nodejs-npm

# copy over gems and application
COPY --from=web-app-gems --chown=docker:docker /usr/local/bundle /usr/local/bundle
COPY --chown=docker:docker web/ $APP_HOME
COPY --chown=docker:docker build/web-app-entrypoint /usr/local/bin/entrypoint

USER docker
RUN npm install
RUN npm run build
RUN bundle exec rake assets:precompile

EXPOSE 3001
CMD [ "/usr/local/bin/entrypoint", "start" ]

##### Extension server container #######################################################################
FROM base as ext-server

# Install additional packages
RUN apk add --no-cache nodejs nodejs-npm git

# copy over gems and application
COPY --from=ext-server-gems --chown=docker:docker /usr/local/bundle /usr/local/bundle
COPY --chown=docker:docker extensions/ $APP_HOME
COPY --chown=docker:docker build/ext-server-entrypoint /usr/local/bin/entrypoint

USER docker
RUN npm install
RUN rake extensions:build

ENV PATH="${APP_HOME}node_modules/.bin:${PATH}"

EXPOSE 8001
CMD [ "/usr/local/bin/entrypoint", "start" ]
