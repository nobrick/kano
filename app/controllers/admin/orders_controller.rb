class Admin::OrdersController < Admin::ApplicationController
  def index
    @orders = Order.page(params[:page]).per(10)
  end

  helper_method :dashboard

  def dashboard
    @dashboard = ::OrderDashboard.new
  end
end
