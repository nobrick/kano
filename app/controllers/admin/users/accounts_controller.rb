class Admin::Users::AccountsController < Admin::ApplicationController

  helper_method :dashboard

  def index
    @users = User.page(params[:page]).per(10)
  end

  def dashboard
    @dashboard = ::UserDashboard.new
  end
end
