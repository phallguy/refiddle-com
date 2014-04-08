class UsersController < ApplicationController
  load_and_authorize_resource :user, parent: false

  def index
    @users = User.accessible_by(current_ability)
    @users = paged(@users)
  end

  def show
  end

  def update
    @user.write_attributes(user_params)
    render_modified_response @user    
  end

  private


    def user_params
      params.fetch(:user,{}).permit(:name,:email)
    end

  
end