class Admin::ManagersController < Admin::ApplicationController

  helper_method :dashboard

  def index
    q_params = dashboard.search_params(params)
    @search = Account.where(admin: true).ransack(q_params)
    @managers = @search.result.page(params[:page]).per(10)
  end

  private

  def nav_links
    {}
  end

  def dashboard
    @dashboard = ::ManagerDashboard.new
  end
end
