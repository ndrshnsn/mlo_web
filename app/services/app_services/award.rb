class AppServices::Award < ApplicationService
  def list_awards
    award_list
  end

  private

  def award_list
    awards = []
    awards.push(
      { position: "firstplace", i18n: "awardTypes.firstplace", i18n_desc: "awardTypes.firstplace_desc"},
      { position: "secondplace", i18n: "awardTypes.secondplace", i18n_desc: "awardTypes.secondplace_desc"},
      { position: "thirdplace", i18n: "awardTypes.thirdplace", i18n_desc: "awardTypes.thirdplace_desc"},
      { position: "fourthplace", i18n: "awardTypes.fourthplace", i18n_desc: "awardTypes.fourthplace_desc"},
      { position: "goaler", i18n: "awardTypes.goaler", i18n_desc: "awardTypes.goaler_desc"},
      { position: "assister", i18n: "awardTypes.assister", i18n_desc: "awardTypes.assister_desc"},
      { position: "fairplay", i18n: "awardTypes.fairplay", i18n_desc: "awardTypes.fairplay_desc"},
      { position: "lessown", i18n: "awardTypes.lessown", i18n_desc: "awardTypes.lessown_desc"}
    )

    awards
  end
end