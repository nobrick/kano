class Admin::ApplicationController < ActionController::Base
  layout "admin"

  before_filter :authenticate_admin

  def authenticate_admin
    redirect_to root_url, alert: 'PERMISSION DENIED' unless current_user.try :admin?
    true
  end

  helper_method :nav_links, :in_scope?, :page_identifier


  def in_scope?(parent_path)
    request.path =~ /^#{parent_path}/
  end

  def page_identifier
    controller = params[:controller].tr('/', '-')
    action = params[:action]
    "#{controller}-#{action}"
  end

  # TODO 想想有没有其他好的显示办法
  def nav_links
    [
      {
        text: "handymen_admin",
        path: admin_handyman_certifications_path,
        scope: '/admin/handymen'
      },
      {
        text: "users_admin",
        path: '/',
        scope: '/admin/users'
      },
      {
        text: "orders_admin",
        path: "/",
        scope: '/admin/orders'
      },
      {
        text: "balance_admin",
        path: "/",
        scope: '/admin/balance'
      }
    ]
  end

end
