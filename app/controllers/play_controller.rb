require 'regex_runner'

class PlayController < ApplicationController
  skip_authorization_check

  # TODO anti-leeching to make sure requests originate from refiddle.com

  def replace
    sleep 3
    render json: runner.replace( params[:pattern], params[:corpus_text], params[:replace_text] )
  end

  def evaluate
    sleep 3
    render json: runner.match( params[:pattern], params[:corpus_text] )
  end

  private

    def runner
      @runner ||= RegexRunner.find(params[:flavor])
    end


end