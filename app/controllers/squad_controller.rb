class SquadController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact, turbo: "false"
  breadcrumb "squad.main", :squad_path, match: :exact, frame: "main_frame"

  def index
  end

  def set_controller_vars
    @season = Season.find(session[:season])
  end
end