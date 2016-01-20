class Admin::Users::AccountsController < Admin::AccountsController
  def index
    @users = User.page(params[:page]).per(10)
  end

  def dashboard
    @dashboard = ::UserDashboard.new
  end

  helper_method :dashboard
end
