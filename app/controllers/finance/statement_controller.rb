class Finance::StatementController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "finance.main", :root_path, match: :exact, frame: "main_frame"
  breadcrumb "finance.statement.main", :finance_statement_path, match: :exact, frame: "main_frame"

  def index
    @club_cash = Club.getFunds(@club.id)

    @statement_age = !params[:statement_age].nil? ? params[:statement_age] : "last_15_days"

    case @statement_age
    when "last_15_days"
        age = "created_at > '#{15.days.ago}'"
    when "last_30_days"
        age = "created_at > '#{30.days.ago}'"
    when "last_60_days"
        age = "created_at > '#{60.days.ago}'"
    when "last_90_days"
        age = "created_at > '#{90.days.ago}'"
    when "all_season"
        age = "created_at < '#{Date.tomorrow}'"
    end

    @statement_operation = params[:statement_operation].nil? ? "any" : params[:statement_operation]
    @statements = ClubFinance.where(club_id: session[:userClub]).where(age).order('created_at ASC')

    if @statement_operation != "any"
        @statements = @statements.where("operation LIKE ?", @statement_operation)
    end

  end

  def detail
    @statement = ClubFinance.find(params[:id])

    respond_to do |format|
      format.turbo_stream { render "finance/statement/detail", locals: { statement: @statement } }
    end
  end

  def set_controller_vars
    @season = Season.find(session[:season])
    @club = User.getClub(current_user.id, @season.id)
  end
end
