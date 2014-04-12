require 'analytics-ruby'
Analytics = AnalyticsRuby
Analytics.init( 
  secret: Settings.segmentio.secret,
  on_error: Proc.new { |status, error| Rails.logger.error "Couldn't report analytics: #{error}" }
 )