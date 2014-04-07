source 'https://rubygems.org'

gem 'rails', '4.0.4'

gem 'rapped', path: "~/Projects/phallguy/rapped"
# gem 'rapped', git: "git@github.com:phallguy/rapped.git"

gem 'jquery-rails'
gem 'less-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', platforms: :ruby
gem 'jbuilder', '~> 1.2'
gem 'cancan'
gem 'omniauth-openid'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem "non-stupid-digest-assets"
gem 'mongoid', github: 'mongoid/mongoid' 
gem 'moped', github: 'mongoid/moped' 
gem "mongoid_slug", github: "digitalplaywright/mongoid-slug"
gem 'mongoid-tags-arent-hard'
gem 'rails_config'
gem 'haml'

group :development, :test do
  gem 'awesome_print', :require => false
  gem 'spring'
  gem 'byebug', github: "deivid-rodriguez/byebug"
  gem 'pry-byebug', github: "deivid-rodriguez/pry-byebug"
  gem 'ruby-prof'
end


group :development do
  gem 'foreman'
  # gem 'capi-sous', path: "~/Projects/phallguy/capi-sous"
  gem 'capi-sous', git: "git@github.com:phallguy/capi-sous.git"
  gem 'yard'
end

group :test do
  gem 'vcr', github: 'vcr/vcr'
  gem 'growl'  
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'rb-fsevent'
  gem 'rspec-rails'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spring'
  gem 'spring-commands-rspec'
  gem 'rspec-http'
  gem 'database_cleaner'
  gem 'fakeweb'
  gem 'timecop'
  gem "json_spec"
end




# PRODUCTION
gem 'rack-handlers'
gem 'unicorn'
