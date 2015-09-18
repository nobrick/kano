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

  %w{ User Handyman }.each do |resource|
    define_method "current_#{resource.underscore}" do
      current_account if current_account.is_a? resource.constantize
    end

    define_method "#{resource.underscore}_signed_in?" do
      !!send("current_#{resource.underscore}")
    end

    define_method "authenticate_#{resource.underscore}!" do
      unless send("current_#{resource.underscore}")
        set_return_path
        redirect_to new_account_session_path, alert: t('devise.failure.unauthenticated')
      end
    end
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
