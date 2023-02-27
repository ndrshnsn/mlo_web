module FakeAccounts
  extend ActiveSupport::Concern

  def createFakeAccounts(league)
    for i in 1..league.slots do
      user = self.createFake
      if user
        uLeague = UserLeague.new(
          league_id: league.id,
          user_id: user.id,
          status: true
        ).save!
      end
    end
  end

  def createFake
    require 'securerandom'
    fakeId = SecureRandom.hex(8)
    user = User.new(
      email: "mlo_user_#{fakeId}@local",
      role: 'user',
      full_name: "mlo_user #{fakeId.last(4)}",
      password: AppConfig.fake_account_password,
      password_confirmation: AppConfig.fake_account_password,
      active: true,
      nickname: "mlo_#{fakeId.last(4)}",
      preferences: {
        fake: true
      }
    )

    if user.save!
      return user
    else
      return false
    end
  end

  def removeFakeAddUser(fake, user, league)
    prevUleague = UserLeague.find_by(league_id: league.id, user_id: user.id)

    uLeague = UserLeague.where(league_id: league.id, user_id: fake.id)
    uLeague.update_all(user_id: user.id, status: true)

    uSeason = UserSeason.where(user_id: fake.id)
    uSeason.update_all(user_id: user.id)
    
    uNotifications = Notification.where(recipient_id: fake.id)
    uNotifications.update_all(recipient_id: user.id)

    user.preferences["request"] = false
    if user.save! && fake.destroy! && prevUleague.destroy!
      return true
    end
    return false      
  end

  def moveUsersBetween(origin, destiny, league)
    prevUleague = UserLeague.find_by(league_id: league.id, user_id: destiny.id)

    uLeague = UserLeague.where(league_id: league.id, user_id: destiny.id)
    uLeague.update_all(user_id: origin.id, status: true)

    uSeason = UserSeason.where(user_id: destiny.id)
    uSeason.update_all(user_id: origin.id)
    
    uNotifications = Notification.where(recipient_id: destiny.id)
    uNotifications.update_all(recipient_id: origin.id)

    user.preferences["request"] = false
    prevUleague.update(status: false)
    if user.save!
      return true
    end
    return false      
  end

  def fakeSlots(league)
    return UserLeague.joins(:user).where("user_leagues.league_id = ? AND users.preferences -> 'fake' = ?", league.id, "true").size
  end

  def removeUserCreateFake(user, league)
    newFake = self.createFake()
    uLeague = UserLeague.find_by(league_id: league.id, user_id: user.id)
    if uLeague.update(user_id: newFake.id)
      uSeason = UserSeason.where(user_id: user.id)
      uSeason.update_all(user_id: newFake.id)
      
      uNotifications = Notification.where(recipient_id: user.id)
      uNotifications.update_all(recipient_id: newFake.id)

      return true
    else
      return false
    end
  end

  def disableUserCreateFake(user, league)
    uLeague = UserLeague.find_by(league_id: league.id, user_id: user.id)
    newFake = self.createFake()

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
      return true
    else
      return false
    end
  end
end