module FakeAccounts
  extend ActiveSupport::Concern

  # def createFakeAccounts(league)
  #   for i in 1..league.slots do
  #     user = createFake
  #     if user
  #       uLeague = UserLeague.new(
  #         league_id: league.id,
  #         user_id: user.id,
  #         status: true
  #       ).save!
  #     end
  #   end
  # end

  # def createFake
  #   require "securerandom"
  #   fakeId = SecureRandom.hex(8)
  #   user = User.new(
  #     email: "mlo_user_#{fakeId}@local",
  #     role: "user",
  #     full_name: "mlo_user #{fakeId.first(4)}",
  #     password: AppConfig.fake_account_password,
  #     password_confirmation: AppConfig.fake_account_password,
  #     active: true,
  #     nickname: "mlo_#{fakeId.first(4)}",
  #     preferences: {
  #       fake: true
  #     }
  #   )

  #   if user.save!
  #     user
  #   else
  #     false
  #   end
  # end

  def removeFakeAddUser(fake, user, league)
    prevUleague = UserLeague.find_by(league_id: league.id, user_id: user.id)

    uLeague = UserLeague.where(league_id: league.id, user_id: fake.id)
    uLeague.update_all(user_id: user.id, status: true)

    uSeason = UserSeason.where(user_id: fake.id)
    uSeason.update_all(user_id: user.id)

    uNotifications = Notification.where(recipient_id: fake.id)
    uNotifications.update_all(recipient_id: user.id)

    user.preferences["request"] = false
    user.preferences["active_league"] = league.id
    if user.save! && fake.destroy! && prevUleague.destroy!
      return true
    end
    false
  end

  def move_users_between(origin, destiny, league)
    prev_user_league = UserLeague.find_by(league_id: league.id, user_id: destiny.id)

    user_league = UserLeague.where(league_id: league.id, user_id: destiny.id)
    user_league.update_all(user_id: origin.id, status: true)

    user_season = UserSeason.where(user_id: destiny.id)
    user_season.update_all(user_id: origin.id)

    notifications = Notification.where(recipient_id: destiny.id)
    notifications.update_all(recipient_id: origin.id)

    destiny.preferences["request"] = false
    prev_user_league.update(status: false)
    if destiny.save
      true
    else
      false
    end
  end
  
  def fakeSlots(league)
    UserLeague.joins(:user).where("user_leagues.league_id = ? AND users.preferences -> 'fake' = ?", league.id, "true").size
  end

  def removeUserCreateFake(user, league)
    newFake = createFake
    uLeague = UserLeague.find_by(league_id: league.id, user_id: user.id)
    if uLeague.update(user_id: newFake.id)
      user.preferences["active_league"] = nil
      user.save!

      uSeason = UserSeason.where(user_id: user.id)
      uSeason.update_all(user_id: newFake.id)

      uNotifications = Notification.where(recipient_id: user.id)
      uNotifications.update_all(recipient_id: newFake.id)

      true
    else
      false
    end
  end

  def disableUserCreateFake(user, league)
    uLeague = UserLeague.find_by(league_id: league.id, user_id: user.id)
    newFake = createFake

    moveOldUser = UserLeague.new(
      league_id: league.id,
      user_id: user.id,
      status: false
    ).save!

    uSeason = UserSeason.where(user_id: user.id)
    uSeason.update_all(user_id: newFake.id)

    uNotifications = Notification.where(recipient_id: user.id)
    uNotifications.update_all(recipient_id: newFake.id)

    if uLeague.update(user_id: newFake.id)
      # Check for any other league that user is member
      if UserLeague.where(user_id: user.id).count > 1
        user.preferences["active_league"] = UserLeague.where(user_id: user.id).where.not(league_id: league.id).first.id
      else
        user.preferences["active_league"] = nil
      end
      user.save!

      true
    else
      false
    end
  end
end
