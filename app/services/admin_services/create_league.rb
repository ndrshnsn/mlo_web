class AdminServices::CreateLeague < ApplicationService
  def initialize(league, params)
    @league = league
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      create_league
    end
  end

  private

  def create_league
    return OpenStruct.new(success?: false, league: nil, errors: @league.errors) unless @league.save!

    adm = User.find(@params[:user_id])
    if adm.update!(
      request: false,
      active_league: @league.id,
      role: "manager"
      )

      @league.slots.times do |i|
        create_fake = AppServices::Users::CreateFake.call
        if create_fake.user
          UserLeague.new(
            league_id: @league.id,
            user_id: create_fake.user.id,
            status: true
          ).save!
        end
      end
    end
    AdminMailer.with(league: @league).create_league.deliver_later
    OpenStruct.new(success?: true, league: @league, errors: nil)
  end
end
