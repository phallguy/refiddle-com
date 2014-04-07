class RevisionsController < ApplicationController
  load_and_authorize_resource :refiddle
  skip_authorize_resource :refiddle_pattern, except: :revert

  def index
    @refiddle_patterns = paged( @refiddle.revisions )
  end

  def show
  end

end