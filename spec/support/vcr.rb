require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.join( Rails.root, 'spec/fixtures/cassettes' )
  c.hook_into :fakeweb
  c.configure_rspec_metadata!

  c.ignore_request do |request|
    # Ignore local elastic search requests
    URI(request.uri).port == 9200
  end
end