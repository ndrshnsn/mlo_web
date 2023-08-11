require 'rails_helper'

RSpec.describe Season, type: :model do
  describe '#season?' do
    it 'tries to create a season' do
      season = create(:season)
      expect(season.status).to eq(0)
    end
  end
end