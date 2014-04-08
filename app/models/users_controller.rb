class UsersController < ApplicationController
  load_and_authorize_resource :user, parent: false

  def index
    @users = User.accessible_by(current_ability)
    @users = paged(@users)
  end

  def edit
  end

  def show
  end

  def update
    @user.write_attributes(user_params)
    render_modified_response @user    
  end

  private


    def user_params

      allowed = [:name,:email]

      if can?(:assign_roles,@user) || can?(:assign_roles,User)
        allowed = [roles:[]]
      end

      params.fetch(:user,{}).permit(allowed)
    end

  
end