class Ability
  include CanCan::Ability

  def initialize(user, controller_namespace = nil)
    user ||= User.new

    case controller_namespace
    when "Manager"
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
      user_acls = AppServices::Users::Acl.new(params: nil, user: user.id).get_acls
      user_acls.each do |permission|
        can permission[:role].split("::").last.to_sym, permission[:role].split("::").first.to_sym
      end

    when "Admin"
      if user.admin?
        can :manage, :all
      end
    when "Admin::Playerdb"
      if user.admin?
        can :manage, :all
      end
    when "Admin::Insights"
      if user.admin?
        can :manage, :all
      end
    end
  end
end
