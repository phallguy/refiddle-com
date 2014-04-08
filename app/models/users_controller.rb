class UsersController < ApplicationController
  load_and_authorize_resource :user, parent: false

  def index
    @users = User.accessible_by(current_ability)
    @users = paged(@users)
  end

  def show
  end

  def new
  end

  def create
  end

  def update
  end

  
end