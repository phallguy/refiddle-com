class ForksController < ApplicationController
  load_and_authorize_resource :refiddle

  def index
    @forks = paged(@refiddle.forks)
  end

  def create
    @fork = @refiddle.fork!(current_user)
    render_modified_response @fork, path: refiddle_url(@fork)
  end


  private
     def fork_params
      params.fetch(:refiddle,{}).permit(
        :title,:description,:share,:locked,:corpus_deliminator,:tags,
        pattern_attributes: [:regex,:corpus_text,:replace_text]
        )
    end


end