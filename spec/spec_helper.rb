# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'rubygems'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment.rb",  __FILE__)


require 'rails/all'
require 'rspec/rails'
require 'factory_girl_rails'
require 'rails/mongoid'
require 'capybara/rspec'

# require 'rspec/autorun' (causes Zeus to run specs twice)

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include FactoryGirl::Syntax::Methods
  config.include JsonSpec::Helpers

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.filter_run_excluding :broken => true
  config.filter_run_excluding :remote => true
  config.filter_run_excluding :slow => true
  config.filter_run_excluding :ignore => true
  config.run_all_when_everything_filtered = true
  
  config.filter_run_excluding :slow unless ENV["SLOW_SPECS"]
  
  config.before(:each) { GC.disable }
  config.after(:each) { GC.enable }
  config.before(:each){ FakeWeb.allow_net_connect = false }

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with :truncation
    ::Settings.reload!
    # @preloaded_models ||= ::Mongoid.preload_models
    # ::Mongoid::Tasks::Database.create_indexes
  end

  config.before(:each) do
    DatabaseCleaner[:mongoid].start
    Rails.cache.clear
  end

  config.after(:each) do
    DatabaseCleaner[:mongoid].clean
  end

end

