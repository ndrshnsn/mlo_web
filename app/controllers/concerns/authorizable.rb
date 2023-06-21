module Authorizable
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied do |exception|
      if Rails.env.development?
        matching_rules = current_ability.send(:relevant_rules_for_match, exception.action, exception.subject)
    
        if matching_rules.any?
          describe_rules = matching_rules.map {|rule| { conditions: rule.conditions, block: rule.instance_variable_get(:@block) } }
    
          Rails.logger.debug "CanCanCan::AccessDenied: User has ability to #{exception.action} " \
                             "#{exception.subject.inspect}, but failed to satisfy conditions: " \
                             "#{describe_rules.to_sentence(two_words_connector: ' or ', last_word_connector: ' or ')}"
        else
          Rails.logger.debug "CanCanCan::AccessDenied: User does not have ability to #{exception.action} " \
                             "#{exception.subject.inspect}"
        end
      end

      flash.now[:danger] = t("unauthorized")
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream:
            [
              turbo_stream.update("dashboard", partial: "dashboard/main"),
              turbo_stream.update("flash", partial: "layouts/flash/main")
            ]
        end
        format.html { redirect_to root_path, error: t("unauthorized") }
      end
    end
  end

  private

  def current_ability
    controller_name_segments = params[:controller].split("/")
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join("/").camelize
    Ability.new(current_user, controller_namespace)
  end
end
