class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def wechat
    wechat_callback_for 'User'
  end

  def handyman_wechat
    wechat_callback_for 'Handyman'
  end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/wechat/callback
  def failure
    redirect_to root_path, alert: t('.failure')
  end

  private

  def wechat_callback_for(type)
    auth = request.env['omniauth.auth']
    @account = Account.from_omniauth(auth, type)
    if @account.persisted?
      omniauth_sign_in(type)
    else
      Rails.logger.debug "wechat persistence failed: #{@account.errors.full_messages}"
      redirect_to root_url, alert: t('.persist_failure')
    end
  end

  def omniauth_sign_in(type)
    scope = @account.type.underscore
    sign_in(scope, @account)
    redirect_after_sign_in(type)
  end

  def redirect_after_sign_in(type)
    if type == 'Handyman' && !@account.completed_info?
      redirect_to complete_handyman_profile_url
      return
    end
    redirect_to root_url
  end

  # protected

  # The path used when omniauth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
