module ApplicationHelper
  include DatatablesHelper

  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash", partial: "layouts/flash/main"
  end

  def flashClass(level)
    case level
    when "info" then "primary"
    when "success" then "success"
    when "error" then "danger"
    when "warning" then "warning"
    end
  end

  def socialProviders
    [
      ["google_oauth2", t("social_providers.google_oauth2")],
      ["twitter", t("social_providers.twitter")],
      ["github", t("social_providers.github")]
    ]
  end

  def i18n_set? key
    I18n.t key, raise: true
  rescue
    false
  end

  def avatarURL(user)
    user = user.reload
    return user.identities.last.gravatar_url if user.identities.present?
    return asset_path("generic-avatar.png") if user.avatar_data.blank?
    user.avatar_url
  end

  def leagueBadge(league)
    league = league.reload
    return asset_path("generic-league.png") if league.badge_data.blank?
    league.badge_url
  end

  def awardTrophy(award)
    if award.new_record?
      asset_path("generic-trophy.png")
    else
      award = award.reload
      return asset_path("generic-trophy.png") if award.trophy_data.blank?
      award.trophy_url
    end
  end

  def championshipBadge(championship)
    if championship.new_record?
      asset_path("generic-trophy.png")
    else
      championship = championship.reload
      if championship.badge_data.blank?
        return asset_path("generic-trophy.png")
      end
      championship.badge_url
    end
  end

  def stringHuman(string)
    string.split.map(&:capitalize).join(" ")
  end

  def toCurrency(value)
    number_to_currency(value, unit: "#{I18n.t("money_sign")} ", separator: ".", delimiter: ".", precision: 0)
  end

  def countryFlag(country)
    if !File.exist?("#{Dir.pwd}/app/assets/images/flags/#{DefCountry.getISO(country.humanize)}.svg")
      return image_path("generic-flag.png")
    end
    image_path("flags/#{DefCountry.getISO(country.humanize)}.svg")
  end

  def defTeamBadgeURL(prefix, defTeam)
    url = "#{prefix}/teams/#{defTeam.name.upcase.delete(" ")}.png"
    if image_exists?(url)
      return "#{prefix}/teams/#{defTeam.name.upcase.delete(" ")}.png"
    end
    image_path("/misc/generic-team.png")
  end

  def getRandomCard
    "cards/#{Dir.glob("app/assets/images/cards/*.png").map { |s| File.basename(s) }.sample}"
  end

  def image_exists?(url)
    response = {}
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request # Net::HTTPResponse object
    end
    response.content_type.starts_with?("image")
  end

  def team_formations
    Array[
      {id: 0, name: "4-3-3", pos: ["GK", "LB", "LCB", "RCB", "RB", "LCMF", "DMF", "RCMF", "LWF", "CF", "RWF"]},
      {id: 1, name: "4-2-1-3", pos: ["GK", "LB", "LCB", "RCB", "RB", "LDCMF", "RDMF", "AMF", "LWF", "CF", "RWF"]},
      {id: 2, name: "4-1-3-2", pos: ["GK", "LB", "LCB", "RCB", "RB", "DMF", "LMF", "AMF", "RMF", "LCF", "SS"]},
      {id: 3, name: "4-3-1-2", pos: ["GK", "LB", "LCB", "RCB", "RB", "LCMF", "DMF", "RCMF", "AMF", "LCF", "SS"]},
      {id: 4, name: "4-2-2-2", pos: ["GK", "LB", "LCB", "RCB", "RB", "LDCMF", "RDMF", "LMF", "RMF", "LCF", "SS"]},
      {id: 5, name: "4-1-4-1", pos: ["GK", "LB", "LCB", "RCB", "RB", "DMF", "LMF", "RAMF", "LAMF", "RMF", "CF"]}
     ]
  end

  def award_result_types
    [
      ["firstplace", t("awardTypes.firstPlace"), t("awardTypes.firstPlace_desc")],
      ["secondplace", t("awardTypes.secondPlace"), t("awardTypes.secondPlace_desc")],
      ["thirdplace", t("awardTypes.thirdPlace"), t("awardTypes.thirdPlace_desc")],
      ["fourthplace", t("awardTypes.fourthPlace"), t("awardTypes.fourthPlace_desc")],
      ["goaler", t("awardTypes.goaler"), t("awardTypes.goaler_desc")],
      ["assister", t("awardTypes.assister"), t("awardTypes.assister_desc")],
      ["fairplay", t("awardTypes.fairplay"), t("awardTypes.fairplay_desc")],
      ["lessown", t("awardTypes.lessown"), t("awardTypes.lessown_desc")]
    ]
  end

  def translate_pkeys(data, platform)
    list_of = ["PES", "FIFA"]
    platform = list_of.include?(platform) ? platform : get_platforms(platform: platform, dna: true)

    case platform
    when "PES"
      tvalues = {
        "Right foot" => t("playerdb.players.rightFoot"),
        "Left foot" => t("playerdb.players.leftFoot"),
        "CF" => [t("playerdb.players.pos.pes.cf"), "Forward"],
        "SS" => [t("playerdb.players.pos.pes.ss"), "Forward"],
        "LWF" => [t("playerdb.players.pos.pes.lwf"), "Forward"],
        "RWF" => [t("playerdb.players.pos.pes.rwf"), "Forward"],
        "AMF" => [t("playerdb.players.pos.pes.amf"), "Midfielder"],
        "LMF" => [t("playerdb.players.pos.pes.lmf"), "Midfielder"],
        "RMF" => [t("playerdb.players.pos.pes.rmf"), "Midfielder"],
        "CMF" => [t("playerdb.players.pos.pes.cmf"), "Midfielder"],
        "DMF" => [t("playerdb.players.pos.pes.dmf"), "Midfielder"],
        "LB" => [t("playerdb.players.pos.pes.lb"), "Defender"],
        "RB" => [t("playerdb.players.pos.pes.rb"), "Defender"],
        "CB" => [t("playerdb.players.pos.pes.cb"), "Defender"],
        "GK" => [t("playerdb.players.pos.pes.gk"), "Goalkeeper"],
        "any" => [t("playerdb.players.any"), "Midfielder"]
      }
    when "FIFA"
      tvalues = {
        "Right" => t("playerdb.players.rightFoot"),
        "Left" => t("playerdb.players.leftFoot"),
        "GK" => [t("playerdb.players.pos.fifa.gk"), "Goalkeeper"],
        "CB" => [t("playerdb.players.pos.fifa.zc"), "Defender"],
        "LB" => [t("playerdb.players.pos.fifa.lb"), "Defender"],
        "RB" => [t("playerdb.players.pos.fifa.rb"), "Defender"],
        "RWB" => [t("playerdb.players.pos.fifa.rwb"), "Defender"],
        "LWB" => [t("playerdb.players.pos.fifa.lwb"), "Defender"],
        "CDM" => [t("playerdb.players.pos.fifa.cdm"), "Midfielder"],
        "CM" => [t("playerdb.players.pos.fifa.cm"), "Midfielder"],
        "RM" => [t("playerdb.players.pos.fifa.rm"), "Midfielder"],
        "LM" => [t("playerdb.players.pos.fifa.lm"), "Midfielder"],
        "CAM" => [t("playerdb.players.pos.fifa.cam"), "Midfielder"],
        "RW" => [t("playerdb.players.pos.fifa.rw"), "Forward"],
        "LW" => [t("playerdb.players.pos.fifa.lw"), "Forward"],
        "CF" => [t("playerdb.players.pos.fifa.cf"), "Forward"],
        "ST" => [t("playerdb.players.pos.fifa.st"), "Forward"],
        "any" => [t("playerdb.players.any"), "Midfielder"]
      }
    end
    tvalues[data]
  end

  def check_ability(user, namespace, action, method)
    return Ability.new(current_user, namespace).can? action.to_sym, method.to_sym
  end

  def get_platforms(level: nil, platform: nil, dna: false)
    global_platforms = AppConfig.platforms
    return global_platforms.each.detect { |i| i[1].include?(platform) }[0] if dna == true
    return global_platforms.collect {|i| i[level]} if level != nil
    return global_platforms.find {|i| i=platform}[1] if platform != nil
    global_platforms
  end

  ##
  # Translate Overall Ratings to Show it in accordingly colour.
  def translate_pscore(data)
    value = data.to_i
    if value < 70
      color = "bg-secondary"
    elsif value >= 70 and value < 75
      color = "bg-success"
    elsif value >= 75 and value < 80
      color = "bg-info"
    elsif value >= 80 and value < 90
      color = "bg-warning"
    elsif value >= 90
      color = "bg-danger"
    end
    color
  end

  ##
  # List of Player Positions to be sorted
  def playerSortPositions
    ["GK", "CB", "RB", "LB", "DMF", "CMF", "RMF", "LMF", "AMF", "RWF", "LWF", "SS", "CF"]
  end

  def getVisualPlayerPositions(defPlayer)
    positions = {}
    defPlayer.details["positions"].each do |position|
      case defPlayer.platform
      when "PES"
        if position[0] != "pos0"
          positions[position[1]] = if position[1] == defPlayer.def_player_position.name
            "#{position[1]} main"
          else
            position[0]
          end
        end
      when "FIFA"
        positions[position] = "pos0"
      end
    end

    positions
  end

  # def getPositions(platform)
  # 	case platform
  # 	when "PES"
  # 		pValues = {
  # 			"GO" => "GK",
  # 			"ZC" => "CB",
  # 			"LD" => "RB",
  # 			"LE" => "LB",
  # 			"VOL" => "DMF",
  # 			"MLG" => "CMF",
  # 			"MLD" => "RMF",
  # 			"MLE" => "LMF",
  # 			"MAT" => "AMF",
  # 			"PTD" => "RWF",
  # 			"PTE" => "LWF",
  # 			"SA" => "SS",
  # 			"CA" => "CF"
  # 		}
  # 	when "FIFA"
  # 		pValues = {
  # 			"GO" => "GK",
  # 			"ZC" => "CB",
  # 			"LD" => "RB",
  # 			"LE" => "LB",
  # 			"ADD" => "RWB",
  # 			"ADE" => "LWB",
  # 			"VOL" => "CDM",
  # 			"MC" => "CM",
  # 			"MD" => "RM",
  # 			"ME" => "LM",
  # 			"MEI" => "CAM",
  # 			"PD" => "RW",
  # 			"PE" => "LW",
  # 			"SA" => "CF",
  # 			"ATA" => "ST"
  # 		}
  # 	end
  # 	return pValues
  # end
end
