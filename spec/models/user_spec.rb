require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#user?' do
    it 'tries to create a normal user' do
      user = create(:user)
      user.role = 0

      expect(user.role).to eq("user")
    end

    it 'tries to create a manager' do
      user = create(:user)
      user.role = 1

      expect(user.role).to eq("manager")
    end

    it 'tries to create an admin' do
      user = create(:user)
      user.role = 2

      expect(user.role).to eq("admin")
    end
  end
end