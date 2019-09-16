# Standardfile
get standardfile server, web app, and extension server running locally.


## Dependencies
* [bundler](https://bundler.io/)
* [docker-compose](https://docs.docker.com/compose/install/)
* [docker](https://docs.docker.com/install/)
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [ruby](https://www.ruby-lang.org/en/documentation/installation/)

Once you have all the dependencies installed from the directory root run
`bundle install`

### Development
You can bootstrap the development setup by running

`rake dev:bootstrap` other useful commands are `rake -T`

once you have things built, you can use `./bin/dc-dev` to start the apps. `/bin/dc-dev` is a very simple wrapper around
`docker-compose` that specifies both `docker-compose.yml`, and `docker-compose.development.yml`.

Examples:
  * `./bin/dc-dev up`
  * `./bin/dc-dev down`
  * `./bin/dc-dev run ruby-server /bin/sh`
  * `./bin/dc-dev exec ruby-server /bin/sh`

#### Running
once you have bootstrapped `rake dev:bootstrap`, and started up the apps `./bin/dc-dev up` you should be able to access
the **web app** at [http://localhost:3001](http://localhost:3001).

The **ruby server** at [http://localhost:3000](http://localhost:3000)

The **extensions server** at [http://localhost:8001](http://localhost:8001)

#### Extensions
**NOTE: Extensions is how the good folks at [standardnotes](https://standardnotes.org/) make money. This repo/setup is NOT meant to replace paying for extensions.
If you want to use the code provided in this repository to host extensions on your own, you should still purchase a subscription. In fact, its the only decent thing to do
and I would highly suggest purchasing the [5 year plan](https://dashboard.standardnotes.org/?p=60) in order to support [standardnotes](https://standardnotes.org/) continued development.**

This repository contains a very simple extensions server, used for local development. If you are of the mindset of wanting to host everything yourself, including extensions you could very easily
setup nginx to server up the extensions as static assets. To test out installing an extension locally

* Go to the web app
* Click on extensions at the bottom
* Click on import
* Add the following url [http://localhost:8001/advanced-markdown-editor/ext.json](http://localhost:8001/advanced-markdown-editor/ext.json) and hit enter

More info, examples, and adding more extensions can be found in `./extensions/extensions.yml.erb`
