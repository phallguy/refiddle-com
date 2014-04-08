class ForksController < ApplicationController
  load_and_authorize_resource :refiddle

  def index
    @forks = paged(@refiddle.forks)
  end

  def create
    @refiddle = @refiddle.fork!( fork_params )
    render_modified_response @refiddle, path: ->{ refiddle_url(@refiddle) }, view: "refiddles/show"
  end


  private
     def fork_params
      params.fetch(:refiddle,{}).permit(
        :title,:description,:share,:locked,:corpus_deliminator,:tags,
        pattern_attributes: [:regex,:corpus_text,:replace_text]
        ).tap do |wl|
        wl[:user] = current_user
      end
    end


end