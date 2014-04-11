# To setup new Ubuntu 13.04 server:
# cap HOSTFILTER=server bootstrap
# cap HOSTFILTER=server deploy:install
# cap HOSTFILTER=server deploy:setup
# cap HOSTFILTER=server deploy

require 'capi_sous'

sous_recipes %W{ monit dotfiles settings rvm nginx unicorn nodejs check mongodb mongoid memcached release rake elasticsearch firewall redis resque }

set :ec2_pem_file, "~/.ssh/backyardplaces.pem"
set :ec2_root_user, "root"
set :s3_backups, false
set :ssl_provider, "godaddy"
set :application, "backyardplaces"
set :domain_name, "bckyrd.com"
set :mailer_host_name, "backyardplaces.com"
set :repository,  "git@bitbucket.org:backyardplaces/backyardplaces-com"
set :ssh_pem_file, "~/.ssh/bckyrd.pem"
set :use_ssl, false

set :monit_email_server, "smtp.mandrillapp.com"
set :monit_service_email, "ops@bckyrd.com"

require './config/boot'
require 'rollbar/capistrano'


set :rollbar_token, '63b959a7eeb945c1948ef013c6c5fd85'

