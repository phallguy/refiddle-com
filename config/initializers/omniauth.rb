Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2 , Settings.google.app_id    , Settings.google.secret    , secure_image_url: true , name: 'google'
  provider :facebook, Settings.facebook.app_id, Settings.facebook.secret, secure_image_url: true, info_fields: "name,email", scope: :email
  provider :twitter, Settings.twitter.app_id, Settings.twitter.secret, secure_image_url: true, info_fields: "name,email", scope: :email
  provider :stackexchange, Settings.stackexchange.app_id, Settings.stackexchange.secret, site: "stackoverflow", public_key: Settings.stackexchange.key
end