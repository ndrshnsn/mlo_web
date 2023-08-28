class AppServices::Games::Start < ApplicationService
  def initialize(game)
    @game = game
  end

  def call
    ActiveRecord::Base.transaction do
      start_game
    end
  end

  private

  def start_game


    return handle_error(@game, @game&.error) unless @game.save!
    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end
end
