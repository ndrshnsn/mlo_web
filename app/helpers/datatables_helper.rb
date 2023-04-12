module DatatablesHelper
  def dt_actionsMenu(mOptions)
    dtActions = "<div class='dropdown d-inline-block'>"
    dtActions += "<button class='btn btn-soft-secondary btn-sm dropdown' type='button' data-bs-toggle='dropdown' aria-expanded='false'><i class='ri-more-2-fill align-middle'></i></button>"
    if mOptions
      dtActions += "<ul class='dropdown-menu dropdown-menu-end'>"
      mOptions.each do |mOption|
        dtActions += "<li>"
        dtActions += "<a href='#{mOption[:link]}' class='dropdown-item #{mOption[:disabled]}' #{mOption[:turbo]}>"
        dtActions += "<i class='#{mOption[:icon]} align-bottom me-2 text-muted'></i>#{mOption[:text]}"
        dtActions += "</a>"
        dtActions += "</li>"
      end
      dtActions += "</ul>"
    end
    dtActions += "</div>"

    dtActions.html_safe
  end
end
