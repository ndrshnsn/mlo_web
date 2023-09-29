class Trades::BuyController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "trades.main", :trades_path, match: :exact, frame: "main_frame"

  def index
    breadcrumb "trades.buy.main", :trades_buy_path, match: :exact, frame: "main_frame"
  end

  def set_controller_vars
    @season = Season.find(session[:season])
  end

  def get_proc_dt
    render json: User::Trades::BuyDatatable.new(view_context)
  end
end