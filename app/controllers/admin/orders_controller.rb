class Admin::OrdersController < Admin::ApplicationController

  helper_method :dashboard

  def index
    q_params = dashboard.filter_params(params)
    @search = Order.ransack(q_params)
    @orders =  @search.result.includes(:handyman, :user).page(params[:page]).per(10).by_latest_updates
  end

  def search
    q_params = dashboard.search_params(params)
    @search = Order.ransack(q_params)
    @orders = @search.result.includes(:handyman, :user).page(params[:page]).per(10)
    render 'index'
  end

  def show
    @order = Order.find params[:id]
  end

  private

  def dashboard
    @dashboard = ::OrderDashboard.new
  end
end
