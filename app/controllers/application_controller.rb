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

  def current_user
    @current_user ||= current_account if current_account.try(:is_a?, User)
  end

  def current_handyman
    @current_handyman ||= current_account if current_account.try(:is_a?, Handyman)
  end

  def user_signed_in?
    !!current_user
  end

  def handyman_signed_in?
    !!current_handyman
  end

end
