set :memcached_memory_limit, 512

%W{beta}.each do |name|
  server "#{name}.#{domain_name}", :app, :web, :memcached, :unicorn, :mongodb
end

set :branch, "master"
set :domain_name, "beta.#{domain_name}"
set :use_ssl, false
set :mongoid_db_name, "backyardplaces_dev"
set :unicorn_autostart, true
