# Rails.application.configure do
#   config.content_security_policy do |policy|
#     if Rails.env.development?
#       policy.style_src :self, :unsafe_inline
#       policy.script_src :self, :unsafe_eval, :unsafe_inline, :blob, "https://#{ViteRuby.config.host}"
#       policy.connect_src :self, "wss://#{ViteRuby.config.host}"
#     end
#   end
# end
