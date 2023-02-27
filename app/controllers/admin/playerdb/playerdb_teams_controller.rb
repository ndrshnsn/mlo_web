class Admin::Playerdb::PlayerdbTeamsController < ApplicationController
  authorize_resource class: false
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "admin.playerdb.main", :admin_playerdb_teams_path, match: :exact
  breadcrumb "admin.playerdb.teams.main", :admin_playerdb_teams_path, match: :exact

  def index
  end

  def edit
    @defTeam = DefTeam.friendly.find(params[:id])
    @defCountries = DefCountry.getSorted
  end

  def new
    @defTeam = DefTeam.new
    @defCountries = DefCountry.getSorted
  end

  def check_lname
    if params[:id].blank?
      team = DefTeam.exists?(name: params[:def_team][:name].upcase) ?  :unauthorized : :ok
    else
      if params[:def_team][:name].upcase == DefTeam.find(params[:id]).name
        team = :ok
      else
        team = DefTeam.exists?(name: params[:def_team][:name].upcase) ?  :unauthorized : :ok
      end
    end
    render body: nil, status: team
  end

  def destroy
    team = DefTeam.friendly.find(params[:id])
    respond_to do |format|
      if team.destroy!
        flash.now["success"] = t('.success')
        format.html { redirect_to admin_playerdb_teams_path, notice: t('.success') }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def create
    require 'nokogiri'
    require 'open-uri'

    doc = Nokogiri::HTML(URI.open(def_team_params[:wikipediaURL], 'User-Agent' => 'firefox'))
    teamName = doc.xpath("//th[contains(text(), 'Medium Name')]/following-sibling::td[1]").text
    teamAbbr = doc.xpath("//th[contains(text(), 'Short Name')]/following-sibling::td[1]").text
    teamFounded = doc.xpath("//th[contains(text(), 'Year Founded')]/following-sibling::td[1]").text
    teamStadium = doc.xpath("//th[contains(text(), 'Stadium Name')]/following-sibling::td[1]").text.split('(')[0]
    teamCapacity = doc.xpath("//span[contains(text(), 'Stadium')]/../a/../text()").text.strip.split('(')[1].split(')')[0].gsub(/[^\d\.]/, '').to_i
    teamCity = doc.xpath("//th[contains(text(), 'Location')]/following-sibling::td[1]").text

    team = DefTeam.new
    team.name = def_team_params[:name]
    team.def_country_id = def_team_params[:def_country_id]
    team.platforms = def_team_params[:platforms]
    team.alias = def_team_params[:alias]
    team.active = def_team_params[:active]
    team.details = {
        wikipediaURL: def_team_params[:wikipediaURL],
        teamName: teamName,
        teamAbbr: teamAbbr,
        teamFounded: teamFounded,
        teamStadium: teamStadium,
        teamCapacity: teamCapacity,
        teamCity: teamCity
    }
    if team.save!
      flash["success"] = t('.success')
    else
      flash["error"] = t('.error')
    end
    redirect_to admin_playerdb_teams_path
  end

  def update
    require 'open-uri'
    require 'nokogiri'
    require 'down'
  
    doc = Nokogiri::HTML(URI.open(def_team_params[:wikipediaURL], 'User-Agent' => 'firefox'))

    teamName = doc.xpath("//h1[@class='h5 heading-component-title']").text.strip
    teamAbbr = doc.xpath("//span[contains(text(), 'Short Name')]/../text()").text.strip
    teamFounded = doc.xpath("//span[contains(text(), 'Year Founded')]/../text()").text.strip
    teamStadium = doc.xpath("//span[contains(text(), 'Stadium')]/../a/text()").text.strip
    teamCapacity = doc.xpath("//span[contains(text(), 'Stadium')]/../a/../text()").text.strip.split('(')[1].split(')')[0].gsub(/[^\d\.]/, '').to_i
    teamCity = doc.xpath("//span[contains(text(), 'Location')]/../text()").text.strip

    team = DefTeam.friendly.find(params[:id])
    if team.update(
      name: def_team_params[:name],
      def_country_id: def_team_params[:def_country_id],
      alias: def_team_params[:alias],
      platforms: def_team_params[:platforms],
      active: def_team_params[:active],
      details: {
          wikipediaURL: def_team_params[:wikipediaURL],
          teamName: teamName,
          teamAbbr: teamAbbr,
          teamFounded: teamFounded,
          teamStadium: teamStadium,
          teamCapacity: teamCapacity,
          teamCity: teamCity
          }
      )
      flash["success"] = t('.success')
    else
      flash["error"] = t('.error')
    end
    redirect_to admin_playerdb_teams_path
  end

  def get_proc_dt
    render json: Admin::Playerdb::TeamsDatatable.new(view_context)
  end

  private
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
