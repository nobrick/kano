class OrdersController < ApplicationController
  before_action :authenticate_completed_user

  # GET /orders
  def index
    @orders = current_user.orders
  end

  # GET /orders/:id
  def show
    @order = Order.find(params[:id])
  end

  # GET
  def new
    @order = current_user.orders.build(arrives_at: 3.hours.since)
    set_address
  end

  # POST
  def create
    @order = current_user.orders.build(order_params)
    if @order.request!
      redirect_to orders_url, notice: '下单成功'
    else
      set_address
      render :new
    end
  end

  private

  def set_address
    address = @order.address
    if address.blank?
      address = current_user.primary_address
      address = @order.build_address(code: address.code, content: address.content)
    end

    @city_code = address.try(:city_code) || '430100'
    @district_code = address.try(:code)
  end

  def order_params
    params.require(:order).permit(:content, :arrives_at, :taxon_code,
                                  address_attributes: [ :code, :content ] )
  end
end
