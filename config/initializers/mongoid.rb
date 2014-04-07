file = File.expand_path File.join( __FILE__, "../../mongoid.local.yml")
if File.exist? file
  Mongoid.load! file
end

Mongoid.preload_models = true