set :memcached_memory_limit, 512

%W{ub-2}.each do |name|
  server "#{name}.#{domain_name}", :app, :web, :memcached, :unicorn, :mongodb, :elasticsearch, :redis, :resque, :rake
end

set :branch, 'master'
set :use_ssl, false
set :mongoid_db_name, "backyardplaces"
set :unicorn_autostart, true
set :unicorn_workers, 8
set :resque_workers, 6
set :nginx_worker_processes, 16
set :s3_backups, true