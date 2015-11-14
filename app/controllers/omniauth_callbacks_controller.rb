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
    redirect_to root_path, alert: '获取您的微信资料失败，请稍后重试'
  end

  private

  def wechat_callback_for(type)
    auth = request.env['omniauth.auth']
    @account = Account.from_omniauth(auth, type)
    if @account.persisted?
      omniauth_sign_in
    else
      Rails.logger.debug "wechat persistence failed: #{@account.errors.full_messages}"
      redirect_to root_url, alert: '暂时无法微信登录。如需帮助，请联系客服。'
    end
  end

  def omniauth_sign_in
    scope = @account.type.underscore
    sign_in(scope, @account)
    if @account.completed_info?
      redirect_to root_url
    else
      redirect_to complete_profile_url_for(scope)
    end
  end

  # protected

  # The path used when omniauth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
