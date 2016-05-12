class Admin::Users::OrdersController < Admin::ApplicationController

  helper_method :dashboard

  def index
    @user = User.find params[:user_id]
    q_params = dashboard.filter_params(params)
    @search = @user.orders.ransack(q_params)
    @orders = @search.result.includes(:handyman, :user).page(params[:page]).per(10).by_latest_updates
  end

  private

  def dashboard
    @dashboard ||= ::User::OrderDashboard.new
  end
end

