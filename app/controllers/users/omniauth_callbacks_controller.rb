class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token
  
      def google_oauth2
        generic_callback('google_oauth2')
      end

      def twitter
        generic_callback('twitter2')
      end
      
      def generic_callback(provider)
        if user_signed_in?
          auth = request.env['omniauth.auth']
          data = auth.except('extra') 
          session[:omniauth] = {
            uid: data.uid,
            email: data.info.email,
            full_name: data.info.name,
            gravatar_url: data.info.image,
            provider: data.provider
          }
  
          if Identity.create_with_omniauth(session[:omniauth], current_user.id)
            flash[:info] = t('pages.register.account_linked')
            redirect_to profile_path(anchor: "profile-social") and return
          end
        end
  
        auth = request.env['omniauth.auth']
        data = auth.except('extra')
        session[:omniauth] = {
          uid: data['uid'],
          email: data['info']['email'],
          full_name: data['info']['name'],
          gravatar_url: data['info']['image'],
          provider: data['provider']
        }
  
        @user = User.from_omniauth(auth)
        if @user.persisted?
          if @user.active == false
            flash[:error] = "Sua conta está desativada! Em caso de dúvidas entre em contato com o suporte."
            redirect_to root_url
          else
            @identity = Identity.find_with_omniauth(session[:omniauth])
            if @identity.nil?
              @identity = Identity.create_with_omniauth(session[:omniauth], @user.id)
            end

            flash[:success] = "Conectado, #agoravai"
            sign_in_and_redirect @user, event: :authentication
          end
        else
          redirect_to register_url
        end
  
      end
  
      def action_missing(provider)
        # Set up authentication/authorizations here, and distribute tasks
        # that are provider specific to other methods, leaving only tasks
        # that work across all providers in this method. 
      end
  
      def failure
        flash[:error] = 'Ocorreu um erro durante o processo de login. Por favor tente novamente mais tarde.'
        redirect_to root_path
      end
  
    end