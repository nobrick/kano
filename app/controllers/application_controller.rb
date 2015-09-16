class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :render_flash?, :enable_render_flash, :disable_render_flash
  helper_method :wechat_request?

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
end
