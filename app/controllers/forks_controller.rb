class ForksController < ApplicationController
  load_and_authorize_resource :refiddle
  load_and_authorize_resource :fork, through: :refiddle, through_association: :forks, class: "Refiddle"

  def index
    @forks = paged(@forks)
  end

  def create
    @fork = @refiddle.fork!(current_user)
    render_modified_response @fork, path: refiddle_url(@fork)
  end

end