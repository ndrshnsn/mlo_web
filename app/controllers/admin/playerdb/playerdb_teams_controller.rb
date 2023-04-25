class Admin::Playerdb::PlayerdbTeamsController < ApplicationController
  authorize_resource class: false
  before_action :set_local_vars, only: %i[edit new update create]
  breadcrumb "dashboard", :root_path
  breadcrumb "admin.playerdb.main", :admin_playerdb_teams_path
  breadcrumb "admin.playerdb.teams.main", :admin_playerdb_teams_path

  def index
  end

  def new
    @defTeam = DefTeam.new
  end

  def edit
    @defTeam = DefTeam.friendly.find(params[:id])
  end

  def check_lname
    team_name = params[:def_team][:name].upcase
    team = if params[:id].blank?
      DefTeam.exists?(name: team_name) ? :unauthorized : :ok
    elsif team_name == DefTeam.find(params[:id]).name
      :ok
    else
      DefTeam.exists?(name: team_name) ? :unauthorized : :ok
    end
    render body: nil, status: team
  end

  def create
    document = scrape_team_data(def_team_params[:wikipediaURL])
    @defTeam = DefTeam.new
    @defTeam.name = def_team_params[:name]
    @defTeam.def_country_id = def_team_params[:def_country_id]
    @defTeam.platforms = def_team_params[:platforms]
    @defTeam.alias = def_team_params[:alias]
    @defTeam.active = def_team_params[:active]
    @defTeam.details = {
      wikipediaURL: def_team_params[:wikipediaURL],
      teamName: document[:teamName],
      teamAbbr: document[:teamAbbr],
      teamFounded: document[:teamFounded],
      teamStadium: document[:teamStadium],
      teamCapacity: document[:teamCapacity],
      teamCity: document[:teamCity]
    }

    respond_to do |format|
      if @defTeam.save!
        @defTeam.reload
        format.html { redirect_to admin_playerdb_teams_path, success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def update
    @defTeam = DefTeam.friendly.find(params[:id])
    document = scrape_team_data(def_team_params[:wikipediaURL])
    respond_to do |format|
      if @defTeam.update(
        name: def_team_params[:name],
        def_country_id: def_team_params[:def_country_id],
        alias: def_team_params[:alias],
        platforms: def_team_params[:platforms],
        active: def_team_params[:active],
        details: {
          wikipediaURL: def_team_params[:wikipediaURL],
          teamName: document[:teamName],
          teamAbbr: document[:teamAbbr],
          teamFounded: document[:teamFounded],
          teamStadium: document[:teamStadium],
          teamCapacity: document[:teamCapacity],
          teamCity: document[:teamCity]
        })

        format.html { redirect_to admin_playerdb_teams_path, success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    team = DefTeam.friendly.find(params[:id])
    respond_to do |format|
      if team.destroy!
        format.html { redirect_to admin_playerdb_teams_path, success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def scrape_team_data(wikipedia_url)
    require "open-uri"
    require "nokogiri"
    doc = Nokogiri::HTML(URI.open(wikipedia_url, "User-Agent" => "firefox"))
    {
      teamName: doc.xpath("//h1[@class='h5 heading-component-title']")&.text&.strip,
      teamAbbr: doc.xpath("//span[contains(text(), 'Short Name')]/../text()")&.text&.strip,
      teamFounded: doc.xpath("//span[contains(text(), 'Year Founded')]/../text()")&.text&.strip,
      teamStadium: doc.xpath("//span[contains(text(), 'Stadium')]/../a/text()")&.text&.strip,
      teamCapacity: doc.xpath("//span[contains(text(), 'Stadium')]/../a/../text()")&.text&.strip.split("(")[1].split(")")[0].gsub(/[^\d.]/, "").to_i,
      teamCity: doc.xpath("//span[contains(text(), 'Location')]/../text()")&.text&.strip
    }
  end

  def get_proc_dt
    render json: Admin::Playerdb::TeamsDatatable.new(view_context)
  end

  private

  def set_local_vars
    @defCountries = DefCountry.getSorted
  end

  def def_team_params
    params.require(:def_team).permit(
      :name,
      :def_country_id,
      :alias,
      :wikipediaURL,
      :active,
      platforms: []
    )
  end
end
