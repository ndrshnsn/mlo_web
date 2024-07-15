require 'rails_helper'

RSpec.describe AppServices::Games::Wo, type: :model do
  describe '#call' do
    let(:game) { create(:game) }

    it 'apply wo to game' do
      AppServices::Games::Wo.call(game).call

      expect(game.status).to eq(4)
    end
  end
end