require 'rails_helper'

RSpec.describe AppServices::Games::Revoke, type: :model do
  describe '#call' do
    let(:game) { create(:game) }

    it 'revoke game' do
      AppServices::Games::Revoke.call(game).call

      expect(game.hscore).to eq(0)
      expect(game.vscore).to eq(0)
      expect(game.status).to eq(4)
    end
  end
end