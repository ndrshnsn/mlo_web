class AppServices::Games::Revoke < ApplicationService
  def initialize(game)
    @game = game
  end

  def call
    ActiveRecord::Base.transaction do
      revoke_game
    end
  end

  private

  def revoke_game
    if @game.status > 0 && @game.status < 100 && @game.mdescription != "revoked"
      return handle_error(@game, @game&.error) unless GameCard.where(game_id: @game.id).destroy_all
      return handle_error(@game, @game&.error) unless ClubGame.where(game_id: @game.id).destroy_all
      Sidekiq::Cron::Job.find("result_confirmation_#{@game.championship.season.id}_#{@game.championship.id}_#{@game.id}").destroy!
    elsif @game.status == 100
      return handle_error(@game, @game&.error) unless AppServices::Games::Earning.new(@game).reversal
      return handle_error(@game, @game&.error) unless AppServices::Ranking.new(game: @game).reversal
    end

    @game.status = 3
    @game.subtype = 2
    @game.hscore = nil
    @game.vscore = nil
    @game.hsaccepted = false
    @game.vsaccepted = false
    @game.hfaccepted = false
    @game.vfaccepted = false
    @game.eresults_id = nil

    return handle_error(@game, @game&.error) unless @game.save!
    OpenStruct.new(success?: true, game: @game, error: nil)
  end

  def handle_error(game, error)
    OpenStruct.new(success?: false, game: @game, error: error)
  end
end
