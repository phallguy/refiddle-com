require 'omniauth-openid'
require 'openid'
require 'openid/store/filesystem'
require 'openid/store/memcache'
require 'dalli'

require 'openid/fetchers'
OpenID.fetcher.ca_file = File.join(Rails.root,'config','ca-bundle.crt')

memcache_client = Dalli::Client.new

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :open_id, name: "google", identifier: "https://www.google.com/accounts/o8/id", store: OpenID::Store::Memcache.new(memcache_client)
  provider :facebook, Settings.facebook.app_id, Settings.facebook.secret, secure_image_url: true, info_fields: "name,email", scope: :email
  # provider :twitter, Settings.twitter.app_id, Settings.twitter.secret, secure_image_url: true, info_fields: "name,email", scope: :email
  provider :twitter, Settings.twitter.app_id, Settings.twitter.secret, secure_image_url: true, info_fields: "name,email", scope: :email
  provider :stackexchange, Settings.stackexchange.app_id, Settings.stackexchange.secret, site: "stackoverflow", public_key: Settings.stackexchange.key
end