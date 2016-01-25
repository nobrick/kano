class Admin::Managers::AccountsController < Admin::AccountsController


  def index
    @managers = Account.where(admin: true).page(params[:page]).per(10)
  end

  helper_method :dashboard

  def dashboard
    @dashboard = ::ManagerDashboard.new
  end
end
