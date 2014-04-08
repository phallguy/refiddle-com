class ProfilesController < ApplicationController
  load_and_authorize_resource :user, parent: false

  def index
    @users = paged(@users)
  end

  def show
    @refiddles = paged(@user.refiddles)
      .shared
      .recent
  end

end