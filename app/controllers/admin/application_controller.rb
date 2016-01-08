class Admin::ApplicationController < ActionController::Base
  layout "admin"

  before_filter :authenticate_admin

  def authenticate_admin
    redirect_to root_url, alert: 'PERMISSION DENIED' unless current_user.try :admin?
    true
  end

  helper_method :nav_links

  def nav_links
    [
      {text: "师傅信息管理", path: "/admin/handymen"},
      {text: "用户信息管理", path: "/"},
      {text: "订单信息管理", path: "/"},
      {text: "财会信息管理", path: "/"}
    ]
  end

end
