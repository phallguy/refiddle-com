require 'net/http'
require 'uri'

class RegexRunner::Remote < RegexRunner::Base
  
  def server
  end
  
  def replace( pattern, corpus_text, replace_text )
    begin
      res = Net::HTTP.post_form( URI.parse( "#{server}replace" ), { :pattern => pattern, :corpus_text => corpus_text, :replace_text => replace_text } )
      json = JSON.parse( res.body )
    rescue
      json = { :error => "Could not replace fiddle on remote runner." }
    end
  end
  
  def match( pattern, corpus_text )
    begin
      res = Net::HTTP.post_form( URI.parse( "#{server}evaluate" ), { :pattern => pattern, :corpus_text => corpus_text } )
      JSON.parse( res.body )
    rescue
      json = { :error => "Could not play fiddle on remote runner." }
    end
  end
  
  
end
