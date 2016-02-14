class Admin::ApplicationController < ActionController::Base
  layout "admin"

  before_filter :authenticate_admin

  helper_method :nav_links, :in_scope?, :page_identifier, :i18n_t

  def authenticate_admin
    redirect_to root_url, alert: 'PERMISSION DENIED' unless current_user.try :admin?
    true
  end

  def in_scope?(parent_path)
    request.path =~ /^#{parent_path}/
  end

  def page_identifier
    controller = params[:controller].tr('/', '-')
    action = params[:action]
    "#{controller}-#{action}"
  end

  def nav_links
    [
      {
        text: "handymen_admin",
        path: admin_handyman_certification_index_path,
        scope: '/alpha/handymen'
      },
      {
        text: "users_admin",
        path: admin_user_account_index_path,
        scope: '/alpha/users'
      },
      {
        text: "orders_admin",
        path: admin_order_index_path,
        scope: '/alpha/orders'
      },
      {
        text: "balance_admin",
        path: "/",
        scope: '/alpha/balance'
      }
    ]
  end

  def i18n_t(key, type, options = {})
    case type
    when "C"
      I18n.t("controllers.#{controller_path}.#{key}", options)
    when "M"
      model = options.delete(:model)
      I18n.t("activerecord.attributes.#{model}.#{key}", options)
    when "D"
      model = options.delete(:model)
      attri = options.delete(:attr)
      I18n.t("#{model}.#{attri}.#{key}")
    end
  end
end
