class Ability
  include CanCan::Ability

  def initialize(user, controller_namespace = nil)
    user ||= User.new

    case controller_namespace
    when 'Manager'
      if user.manager?
        cLeague = League.find(user.preferences["active_league"])
        if cLeague.status == true
          can :manage, :season
          can :manage, :championship
          can :manage, :setting
          can :manage, :user
          can :manage, :award
        end
      end
    when 'Admin'
      if user.admin?
        can :manage, :all
      end
    when 'Admin::Playerdb'
      if user.admin?
        can :manage, :all
      end
    end
  end
end
