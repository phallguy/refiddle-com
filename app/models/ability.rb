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
    can [:update,:share], Refiddle, user: user

    user.roles && user.roles.each{|r| send r if respond_to? r}   

  end


  def anonymous
    can [:read,:new,:create,:fork], Refiddle, share: true
    can [:update], Refiddle, locked: false
  end

  def staff
  end

  def admin
    can :manage, :all
  end


end
