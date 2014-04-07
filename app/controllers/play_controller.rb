require 'regex_runner'

class PlayController < ApplicationController
  skip_authorization_check

  def replace
    render json: runner.replace( params[:pattern], params[:corpus_text], params[:replace_text] )
  end

  def evaluate
    render json: runner.match( params[:pattern], params[:corpus_text] )
  end

  private

    def runner
      @runner ||= RegexRunner.find(params[:flavor])
    end


end