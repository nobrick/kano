class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :render_flash?, :enable_render_flash, :disable_render_flash,
    :current_user, :current_handyman, :user_signed_in?, :handyman_signed_in?, :wechat_request?

  private

  def render_flash?
    @to_render_flash = true if @to_render_flash.nil?
    @to_render_flash
  end

  def enable_render_flash
    @to_render_flash = true
  end

  def disable_render_flash
    @to_render_flash = false
  end

  def wechat_request?
    request.env['HTTP_USER_AGENT'].include?(' MicroMessenger/')
  end

  def account_signed_in?
    user_signed_in? || handyman_signed_in?
  end

  def current_account
    current_user || current_handyman
  end

  def authenticate_completed_user
    return unless authenticate_user!
    unless current_user.completed_info?
      set_return_path
      redirect_to edit_profile_path, alert: '继续操作前请您完善个人资料'
      return false
    end
    true
  end

  def after_sign_in_path_for(resource)
    session['return_to'] || root_url
  end

  def set_return_path
    unless devise_controller? || request.xhr? || !request.get?
      session['return_to'] = request.url
    end
  end
end
