class ClubsController < ApplicationController
  before_action :set_controller_vars
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "clubs", :clubs_path, match: :exact

  def index
    @clubs = Season.getClubs(@season.id)
  end

  def set_controller_vars
    @season = Season.find(session[:season])
  end
end