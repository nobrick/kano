class Admin::Managers::AccountsController < Admin::AccountsController

  helper_method :dashboard

  def index
    @managers = Account.where(admin: true).page(params[:page]).per(10)
  end

  def dashboard
    @dashboard = ::ManagerDashboard.new
  end
end
