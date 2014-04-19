require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.join( Rails.root, 'spec/fixtures/cassettes' )
  c.hook_into :fakeweb
  c.configure_rspec_metadata!

  c.ignore_request do |request|
    case 
    # Ignore feature specs
    when request.headers["user-agent"] == ["Ruby"] then true
    # Ignore local elastic search requests
    when URI(request.uri).port == 9200 then true
    else
      binding.pry
    end
  end
end