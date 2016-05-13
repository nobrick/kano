class Admin::Handymen::OrdersController < Admin::ApplicationController

  helper_method :dashboard

  def index
    @handyman = Handyman.find params[:handyman_id]
    q_params = dashboard.filter_params(params)
    @search = @handyman.orders.ransack(q_params)
    @orders = @search.result.includes(:handyman, :user).page(params[:page]).per(10).by_latest_updates
  end

  private

  def dashboard
    @dashboard ||= ::Handyman::OrderDashboard.new
  end
end
