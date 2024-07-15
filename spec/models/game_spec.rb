require 'rails_helper'

RSpec.describe Game, type: :model do
  describe '#game?' do
    it 'return true if game valid' do
      game = create(:game)

      expect(game.status).to eq(0)
    end

    it 'start a game' do
      game = create(:game)
      game.status = 1

      expect(game.status).to eq(1)
    end

    it 'apply wo to game' do
      game = create(:game)
      game.status = 1

      AppServices::Games::Wo(game)

      expect(game.status).to eq(0)
    end

  end
end