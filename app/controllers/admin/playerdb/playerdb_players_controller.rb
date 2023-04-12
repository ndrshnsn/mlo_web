class Admin::Playerdb::PlayerdbPlayersController < ApplicationController
  authorize_resource class: false
  breadcrumb "dashboard", :root_path, match: :exact
  breadcrumb "admin.playerdb.main", :admin_playerdb_teams_path, match: :exact
  breadcrumb "admin.playerdb.players.main", :admin_playerdb_players_path, match: :exact

  def index
    @defCountries = DefCountry.all.order(name: :asc)
    @platforms = eval(AppConfig.platforms)
  end

  def details
    @defPlayer = DefPlayer.includes(:def_player_position).friendly.find(params[:id])

    ## Player Positions
    @positions = helpers.getVisualPlayerPositions(@defPlayer)
  end

  def toggle
    @defPlayer = DefPlayer.friendly.find(params[:id])
    respond_to do |format|
      if @defPlayer.toggle!(:active)

        # Actions
        pStatus = (@defPlayer.active == true) ? t("defaults.datatables.disable") : t("defaults.datatables.enable")
        pStatusIcon = (@defPlayer.active == true) ? "close" : "check"
        pStatusConfirm = (@defPlayer.active == true) ? t("defaults.datatables.confirm_disable") : t("defaults.datatables.confirm_enable")
        dtActions = [
          {
            link: admin_playerdb_player_details_path(@defPlayer.friendly_id),
            icon: "ri-information-line",
            text: t("defaults.datatables.show"),
            disabled: "",
            turbo: "data-turbo-frame='modal'"
          },
          {
            link: "javascript:;",
            icon: "ri-#{pStatusIcon}-line",
            text: pStatus,
            disabled: "",
            turbo: "data-action='click->confirm#dialog' data-controller='confirm' data-confirm-title-value='#{pStatusConfirm}' data-confirm-icon-value='warning' data-confirm-link-value='#{admin_playerdb_player_toggle_path(@defPlayer.friendly_id)}' data-confirm-action-value='post'"
          }
        ]
        @dtMenu = helpers.dt_actionsMenu(dtActions)

        flash.now["success"] = t(".success")
        format.html { redirect_to admin_playerdb_countries_new_path, notice: t(".success") }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def get_proc_dt
    render json: Admin::Playerdb::PlayersDatatable.new(view_context)
  end

  private
end
