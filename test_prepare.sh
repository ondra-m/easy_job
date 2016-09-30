#!/usr/bin/env bash

# -v print lines as they are read
# -x print lines as they are executed
# -e abort script at first error
set -e

if [[ ! -d ".redmine" ]]; then
  mkdir .redmine
  pushd .redmine
    # Download and extract redmine
    wget "http://www.redmine.org/releases/redmine-3.3.0.tar.gz" -O redmine.tar.gz
    tar xzf redmine.tar.gz --strip 1

    # Init gems
    echo "
      gem 'pry'
      gem 'pry-rails'
      gem 'puma'
      gem 'easy_job', path: '../'
    " > Gemfile.local

    # Init database
    ruby -ryaml -e "
      config = {
        'adapter' => 'postgresql',
        'database' => 'easy_job_redmine',
        'host' => '127.0.0.1',
        'encoding' => 'utf8'
      }
      config = { 'development' => config, 'production' => config }.to_yaml
      File.write('config/database.yml', config)
    "

    # Install
    bundle --local
    bundle exec rake db:create RAILS_ENV=production
    bundle exec rake db:migrate RAILS_ENV=production
    bundle exec rake generate_secret_token RAILS_ENV=production
    bundle exec rake redmine:load_default_data REDMINE_LANG=en RAILS_ENV=production
  popd
fi
