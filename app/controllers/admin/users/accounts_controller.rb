class Admin::Users::AccountsController < Admin::AccountsController

  helper_method :dashboard

  def index
    @users = User.page(params[:page]).per(10)
  end

  def dashboard
    @dashboard = ::UserDashboard.new
  end
end
