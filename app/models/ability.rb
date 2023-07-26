class Ability
  include CanCan::Ability

  def initialize(user, controller_namespace = nil, params = nil)
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
      user_acls = AppServices::Users::Acl.new(params: nil, user: user.id, league: user.preferences["active_league"]).get_acls
      user_acls.each do |permission|
        can permission[:role].split("::").last.strip.to_sym, permission[:role].split("::").first.strip.to_sym
        if !permission[:extra].nil?
          permission[:extra].split(',').each do |extra_permission|
            can extra_permission.split("::").last.strip.to_sym, extra_permission.split("::").first.strip.to_sym
          end
        end
      end

    when "Admin"
      can :manage, :all if user.admin?
    when "Admin::Playerdb"
      can :manage, :all if user.admin?
    when "Admin::Insights"
      can :manage, :all if user.admin?
    when "Myclub"
      can :manage, :all if user.user?
    end
  end
end
