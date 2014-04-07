class Ability < Rapped::Ability
  include ::CanCan::Ability

  def initialize(user,session,request)
    @user = user
    @session = session
    @request = request
    authenticated if user
    anonymous
  end

  def user
    @user
  end

  def session; @session; end
  def request; @request; end

  def authenticated
    if user.blocked
      cannot :manage, :all
      return
    end

    can [:update,:read], user
    can :read, Dashboard
    can [:update,:create,:read], Business, user: user

    user.roles && user.roles.each{|r| send r if respond_to? r}
    if Rails.env.development?
      can :manage, User if User.in_roles(:admin).empty?
    end

    can [:read], Confirmation, user: user

    can [:index,:read,:update,:destroy,:create], Image, business: { user: user }
    can [:index,:read,:update,:destroy,:create], Video, business: { user: user }
  end


  def anonymous
    can [:read,:suggest], Category if request.format == :json
    can [:read], Business, status: Business::Statuses::LIVE
    can [:read], Video
    can [:read], Image
  end

  def staff
    can :manage, User
    can :manage, Category
    can :manage, Locality
    can :manage, Business
    can :manage, RecentSearch
    can :manage, LegacyRedirect
    can :read, Activity
  end

  def admin
    can :manage, :all
  end

  def yext
    can :manage, DataProvider::Yext
    can [:update,:create,:destroy], Category
  end

end
