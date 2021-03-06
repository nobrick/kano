class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :render_flash?, :enable_render_flash, :disable_render_flash,
    :current_user, :current_handyman, :user_signed_in?, :handyman_signed_in?,
    :wechat_request?, :debug_wechat?, :wechat_request_or_debug?
  before_action :set_gon_data
  before_action :set_exception_data
  rescue_from ActiveRecord::StatementInvalid, with: :handle_statement_invalid

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

  def wechat_request_or_debug?
    wechat_request? || debug_wechat?
  end

  def account_signed_in?
    user_signed_in? || handyman_signed_in?
  end

  def current_account
    current_user || current_handyman
  end

  def authenticate_completed_handyman(options = {})
    return false unless authenticate_handyman!
    unless current_handyman.completed_info?
      sign_up_uncompleted_handyman(options)
      return false
    end
    unless current_handyman.certified?
      redirect_to handyman_taxons_path
      return false
    end
    true
  end

  def sign_up_uncompleted_handyman(options = {})
    unless options[:notice] || options[:alert]
      options[:notice] = t('^should_complete_profile')
    end

    set_return_path
    redirect_to complete_handyman_profile_url, options
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

  def set_alert(message)
    flash[:alert] = message
  end

  def set_notice(message)
    flash[:notice] = message
  end

  def set_return_path
    return if devise_controller? || request.xhr? || !request.get?
    excluding_paths = [ root_path, guides_index_path, handymen_path ]
    return if excluding_paths.include? request.path
    session['return_to'] = request.url
  end

  def set_gon_data
    token = current_account.try(:access_token) || ''
    gon.push(account_access_token: token)
  end

  def set_exception_data
    data = { params: params }
    data.merge!(account_id: current_account.id) if current_account
    request.env['exception_notifier.exception_data'] = data
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

  def handle_statement_invalid
    home = handyman_signed_in? ? handymen_home_index_url : home_index_url
    respond_to do |type|
      type.html { redirect_to home, alert: t('^statement_invalid') }
    end
  end
end
