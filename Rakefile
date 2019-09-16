# frozen_string_literal: true

import 'extensions/Rakefile'
require 'rake/clean'
require 'socket'
require 'timeout'

@root_dir = __dir__

def dc(*args, **params)
  system("#{@root_dir}/bin/dc-dev", *args, **params)
end

def dc_wait_for(*args, app:, service: 'db:3306')
  dc('run', app, '/usr/local/bin/wait-for', service, '--',  *args)
end

namespace 'dev' do
  desc 'bootstraps everything (submodules, docker build, install deps, etc)'
  task bootstrap: %w[submodules build start_db dep_install stop_db]

  desc 'initializes submodules'
  task :submodules do
    system('git', 'submodule', 'update', '--init', '--force', '--remote')

    Dir.chdir("#{@root_dir}/web") do
      system('git', 'submodule', 'update', '--init', '--force', '--remote')
    end
  end

  desc 'runs docker-compose build'
  task :build do
    dc('build', '--pull', '--compress', '--parallel')
  end

  desc 'runs tasks in containers required for dev(such as npm install, etc)'
  multitask dep_install: %w[ext_server ruby_server web_app]

  desc 'build commands for ext-server'
  task :ext_server do
    dc('run', 'ext-server', 'npm', 'install')
    dc('run', 'ext-server', 'rake')
  end

  desc 'build command for ruby-server'
  task :ruby_server do
    dc_wait_for('bundle', 'exec', 'rake', 'assets:precompile', app: 'ruby-server')
    dc_wait_for('bundle', 'exec', 'rake', 'db:create', 'db:migrate', app: 'ruby-server')
  end

  desc 'build command for web-app'
  task :web_app do
    dc('run', 'web-app', 'npm', 'install')
    dc('run', 'web-app', 'npm', 'run', 'build')
    dc('run', 'web-app', 'bundle', 'exec', 'rake', 'assets:precompile')
  end

  task :start_db do
    dc('up', '-d', 'db')
  end

  task :stop_db do
    dc('stop', 'db')
  end

  desc 'removes all images, volumes, and containers'
  task :nuke do
    dc('stop')
    dc('down', '--volumes', '--rmi', 'all', err: File::NULL)
  end
end

Rake::Task[:clean].enhance [:git_clean]

task :git_clean do
  Dir.chdir("#{@root_dir}/web") do
    system('git', 'reset', '--hard')
  end

  Dir.chdir("#{@root_dir}/ruby-server") do
    system('git', 'reset', '--hard')
  end
end

ASSETS_TO_CLEAN = Rake::FileList.new do |fl|
  %w[web ruby-server].each do |d|
    fl.include("#{@root_dir}/#{d}/public/assets") if File.directory?("#{@root_dir}/#{d}/public/assets")
  end
end

CLEAN << ASSETS_TO_CLEAN
