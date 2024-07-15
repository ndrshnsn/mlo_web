class Admin::Playerdb::PlayerdbCountriesController < ApplicationController
  authorize_resource class: false
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "admin.playerdb.main", :admin_playerdb_countries_path, match: :exact
  breadcrumb "admin.playerdb.countries.main", :admin_playerdb_countries_path, match: :exact

  def index
  end

  def new
    @defCountry = DefCountry.new
  end

  def edit
    @defCountry = DefCountry.find(params[:id])
    @cLogoName = DefCountry.getISO(@defCountry.name.humanize)
  end

  def check_name
    country_name = params[:def_country][:name].upcase
    team = if params[:id].blank?
      DefCountry.exists?(name: country_name) ? :unauthorized : :ok
    elsif country_name == DefCountry.find(params[:id]).name
      :ok
    else
      DefCountry.exists?(name: country_name) ? :unauthorized : :ok
    end
    render body: nil, status: team
  end

  def create
    country = DefCountry.new(country_params)
    respond_to do |format|
      if country.save!
        format.html { redirect_to admin_playerdb_countries_path, success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def update
    country = DefCountry.find(params[:id])
    respond_to do |format|
      if country.update(country_params)
        format.html { redirect_to admin_playerdb_countries_path, success: t(".success") }
        format.turbo_stream { flash.now["success"] = t(".success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    country = DefCountry.find(params[:id])
    respond_to do |format|
      if country.destroy!
        flash.now["success"] = t(".success")
        format.html { redirect_to admin_playerdb_countries_path, notice: t(".success") }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def get_proc_dt
    render json: Admin::Playerdb::CountriesDatatable.new(view_context)
  end

  private

  def country_params
    params.require(:def_country).permit(
      :name,
      :alias
    )
  end
end
