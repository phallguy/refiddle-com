class TaggedController < ApplicationController
  skip_authorization_check

  def index
    @tags = Refiddle.all_tags.sort
    @refiddles = paged( Refiddle.shared )
      .recent
  end

  def show
    @tags = Refiddle.all_tags.sort
    @refiddles = paged( Refiddle.with_tags( params[:id] ) )
      .shared
      .recent

    render :index
  end

end