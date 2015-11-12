class Users::OrdersController < ApplicationController
  before_action :authenticate_completed_user
  before_action :set_order, only: [ :show, :charge ]
  before_action :gray_background, only: [ :new, :show ]

  # GET /orders
  def index
    @orders = current_user.orders.order(updated_at: :desc)
  end

  # GET /orders/:id
  def show
    redirect_to user_orders_url, notice: '请求失败' if @order.nil?
    if wechat_request? || debug_wechat?
      url = request.original_url
      gon.push(auth_client(url))
    end
  end

  # GET /orders/new
  def new
    @order = current_user.orders.build(arrives_at: 3.hours.since)
    set_address
  end

  # POST /orders
  def create
    @order = current_user.orders.build(order_params)
    if @order.request && @order.save
      redirect_to [ :user, @order ], notice: '下单成功'
    else
      set_address
      render :new
    end
  end

  # GET /orders/:id/charge
  def charge
    render json: @order.pingpp_charge
  end

  private

  def auth_client(url)
    user_wechat = UserWechatsController.wechat
    signature_options = user_wechat.jsapi_ticket.signature(url)
    {
      pingpp_charge: @order.pingpp_charge,
      order_id: @order.id,
      wechat: {
        appid: user_wechat.access_token.appid,
        timestamp: signature_options.fetch(:timestamp),
        noncestr: signature_options.fetch(:noncestr),
        signature: signature_options.fetch(:signature)
      }
    }
  end

  def set_order
    @order = Order.find(params[:id])
    @order = nil unless @order.user == current_user
  end

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
