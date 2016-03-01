class Admin::OrdersController < Admin::ApplicationController

  helper_method :dashboard

  def index
    @orders = Order.page(params[:page]).per(10)
  end

  def dashboard
    @dashboard = ::OrderDashboard.new
  end
end
