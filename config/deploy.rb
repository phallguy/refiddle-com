# To setup new Ubuntu 13.04 server:
# cap HOSTFILTER=server bootstrap
# cap HOSTFILTER=server deploy:install
# cap HOSTFILTER=server deploy:setup
# cap HOSTFILTER=server deploy

require 'capi_sous'

sous_recipes %W{ monit dotfiles settings rvm nginx unicorn nodejs check mongodb mongoid memcached release rake firewall  }

set :ec2_pem_file, "~/.ssh/refiddle.pem"
set :ec2_root_user, "root"
set :s3_backups, false
set :ssl_provider, "godaddy"
set :application, "refiddle"
set :domain_name, "refiddle.com"
set :mailer_host_name, "refiddle.com"
set :repository,  "git@github.com:phallguy/refiddle-com"
set :ssh_pem_file, "~/.ssh/refiddle.pem"
set :use_ssl, false

set :monit_email_server, "smtp.mandrillapp.com"
set :monit_service_email, "ops@refiddle.com"

require './config/boot'



