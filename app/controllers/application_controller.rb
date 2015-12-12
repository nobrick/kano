class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :render_flash?, :enable_render_flash, :disable_render_flash,
    :current_user, :current_handyman, :user_signed_in?, :handyman_signed_in?,
    :wechat_request?, :debug_wechat?
  before_action :set_gon_data

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
    request.env['HTTP_USER_AGENT'].try(:include?, ' MicroMessenger/')
  end

  def account_signed_in?
    user_signed_in? || handyman_signed_in?
  end

  def current_account
    current_user || current_handyman
  end

  def authenticate_completed_user(options = {})
    return unless authenticate_user!
    if current_user.completed_info?
      true
    else
      sign_up_uncompleted('user', options)
    end
  end

  def authenticate_completed_handyman(options = {})
    return unless authenticate_handyman!
    if current_handyman.completed_info?
      true
    else
      sign_up_uncompleted('handyman', options)
    end
  end

  def complete_profile_url_for(scope)
    case scope.to_s
    when 'user'
      complete_user_profile_url
    when 'handyman'
      complete_handyman_profile_url
    else
      nil
    end
  end

  def sign_up_uncompleted(scope, options = {})
    unless options[:notice] || options[:alert]
      options[:notice] = t('^should_complete_profile')
    end

    set_return_path
    redirect_to complete_profile_url_for(scope), options
    false
  end

  def authenticate_handyman_order(options = {})
    if @order.handyman.present? && @order.handyman != current_handyman
      redirect_to handyman_orders_url, options
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

  def set_gon_data
    token = current_account.try(:access_token) || ''
    gon.push(account_access_token: token)
  end

  def debug_wechat?
    false
  end

  def gray_background
    @body_css_class = 'gray-backgroud'
  end

  def t(key, options = {})
    case key[0]
    when '.'
      I18n.t("controllers.#{controller_path}#{key}", options)
    when '^'
      I18n.t("controllers.root.#{key[1..-1]}", options)
    else
      I18n.t(key, options)
    end
  end
end
