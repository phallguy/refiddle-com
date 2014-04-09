class ForksController < ApplicationController
  load_and_authorize_resource :refiddle

  def index
    @forks = paged(@refiddle.forks)
  end

  def create
    @original = @refiddle
    @refiddle = @refiddle.fork!( fork_params )
    render_modified_response @refiddle, path: ->{ refiddle_url(@refiddle) }, view: "refiddles/show" do
      @original.save
    end
  end


  private
    include HasRefiddleParams
    def fork_params
      refiddle_params
    end


end