# frozen_string_literal: true

import 'extensions/Rakefile'
require 'rake/clean'

@root_dir = __dir__
namespace 'dev' do
  desc 'bootstraps everything (submodules, docker build, install deps, etc)'
  task bootstrap: %w[submodules build dep_install]

  desc 'initializes submodules'
  task :submodules do
    system('git', 'submodule', 'update', '--init', '--force', '--remote')

    Dir.chdir("#{@root_dir}/web") do
      system('git', 'submodule', 'update', '--init', '--force', '--remote')
    end
  end

  desc 'runs docker-compose build'
  task :build do
    system("#{@root_dir}/bin/dc-dev", 'build', '--pull', '--compress', '--parallel')
  end

  desc 'runs tasks in containers required for dev(such as npm install, etc)'
  multitask dep_install: %w[ext_server ruby_server web_app]

  desc 'build commands for ext-server'
  task :ext_server do
    system("#{@root_dir}/bin/dc-dev", 'run', 'ext-server', 'npm', 'install')
    system("#{@root_dir}/bin/dc-dev", 'run', 'ext-server', 'rake')
  end

  desc 'build command for ruby-server'
  task :ruby_server do
    system("#{@root_dir}/bin/dc-dev", 'run', 'ruby-server', 'bundle', 'exec', 'rake', 'assets:precompile')
  end

  desc 'build command for web-app'
  task :web_app do
    system("#{@root_dir}/bin/dc-dev", 'run', 'web-app', 'npm', 'install')
    system("#{@root_dir}/bin/dc-dev", 'run', 'web-app', 'npm', 'run', 'build')
    system("#{@root_dir}/bin/dc-dev", 'run', 'web-app', 'bundle', 'exec', 'rake', 'assets:precompile')
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
