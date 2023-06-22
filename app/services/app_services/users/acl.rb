class AppServices::Users::Acl < ApplicationService
  def initialize(params=nil)
    @params = params
    @user = @params[:user] if @params
    @league = @params[:league] if @params
  end

  def save_acls
    ActiveRecord::Base.transaction do
      update_acl
    end
  end

  def get_acls
    return UserAcl.where(user_id: @user, league_id: @league, permitted: true)
  end

  def list_acls
    acl_list
  end

  private

  def update_acl
    @params[:params].each do |acl_rule|
      acl = UserAcl.where(user_id: @user, role: acl_rule.first).first_or_initialize
      acl.permitted = acl_rule.last
      acl.league_id = @league

      return handle_error(nil, acl&.error) unless acl.save!
    end
    OpenStruct.new(success?: true, error: nil)
  end

  def handle_error(acl, error)
    OpenStruct.new(success?: false, acl: acl, error: error)
  end

  def acl_list
    acls = []
    acls.push(
      {
        type: "season",
        data:
        [
          { role: "season::read", i18n: "season_read" },
          { role: "season::update", i18n: "season_update" }
        ]
      }
    )

    acls.push(
      {
        type: "championship",
        data:
        [
          { role: "championship::read", i18n: "championship_read" },
          { role: "championship::create", i18n: "championship_create" },
          { role: "championship::update", i18n: "championship_update" }
        ]
      }
    )

    acls
  end
end
