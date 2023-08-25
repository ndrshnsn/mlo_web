require 'rails_helper'

RSpec.describe League, type: :model do
  describe '#league?' do
    it 'tries to create a league' do
      league = create(:league)
      expect(league.status).to eq(true)
    end
  end
end