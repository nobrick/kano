class Admin::Managers::AccountsController < Admin::ApplicationController

  helper_method :dashboard

  def index
    @managers = Account.where(admin: true).page(params[:page]).per(10)
  end

  def dashboard
    @dashboard = ::ManagerDashboard.new
  end
end
