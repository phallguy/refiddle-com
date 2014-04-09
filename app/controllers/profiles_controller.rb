class ProfilesController < ApplicationController
  skip_authorize_resource :user
  skip_authorization_check
  load_and_authorize_resource :user, parent: false

  def index
    redirect_to root_path
  end

  def show
    @refiddles = paged(@user.refiddles)
      .shared
      .recent
  end

end