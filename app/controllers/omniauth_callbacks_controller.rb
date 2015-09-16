class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  def wechat
    auth = request.env['omniauth.auth']
    @account = Account.from_omniauth(auth)

    if @account.persisted?
      sign_in_and_redirect @account, :event => :authentication # This will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => '微信') if is_navigational_format?
    else
      # All session data starting with 'devise' will be removed whenever a user signs in
      session['devise.wechat_data'] = auth
      redirect_to new_uni_user_registration_url
    end
  end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/wechat/callback
  def failure
    redirect_to_failure_path
  end

  private

  def redirect_to_failure_path
    redirect_to root_path, alert: '获取您的微信资料失败，请稍后重试'
  end

  # protected

  # The path used when omniauth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
