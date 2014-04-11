set :memcached_memory_limit, 512

%W{ub-1}.each do |name|
  server "#{name}.#{domain_name}", :app, :web, :memcached, :unicorn, :mongodb, :rake
end

set :branch, 'master'
set :use_ssl, false
set :mongoid_db_name, "refiddle_com"
set :unicorn_autostart, true
set :unicorn_workers, 2
set :nginx_worker_processes, 4
set :s3_backups, true