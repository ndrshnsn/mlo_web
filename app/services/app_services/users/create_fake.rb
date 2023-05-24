class AppServices::Users::CreateFake < ApplicationService
  def call
    ActiveRecord::Base.transaction do
      create_fake
    end
  end

  private

  def create_fake
    require "securerandom"

    fake_id = SecureRandom.hex(8)
    user = User.new(
      email: "mlo_user_#{fake_id}@local",
      role: "user",
      full_name: "mlo_user #{fake_id.first(4)}",
      password: AppConfig.fake_account_password,
      password_confirmation: AppConfig.fake_account_password,
      active: true,
      nickname: "mlo_#{fake_id.first(4)}",
      preferences: {
        fake: true
      }
    )
    user.skip_confirmation!

    return OpenStruct.new(success?: false, user: nil, error: user.errors) unless user.save!
    OpenStruct.new(success?: true, user: user, error: nil)
  end
end
