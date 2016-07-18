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

  # PUT /admin/orders/:id/cancel
  def cancel
    opts = { whiny_transition: false }
    transition = Order.serializable_trigger(:cancel, :save, opts) do
      set_order
      @order.assign_attributes(cancel_reason_params)
      @order.tap { |o| o.canceler = current_user }
    end

    if transition
      flash[:success] = i18n_t("cancel_order_success", "C")
    else
      flash[:alert] = i18n_t("cancel_order_failure", "C")
    end

    redirect_to admin_order_path(@order)
  end

  private

  def cancel_reason_params
    params.require(:order).permit(:cancel_reason)
  end

  def set_order
    @order = Order.find(params[:id])
  end

  def dashboard
    @dashboard = ::OrderDashboard.new
  end
end
