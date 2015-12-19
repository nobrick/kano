class Users::OrdersController < ApplicationController
  before_action :authenticate_completed_user
  before_action :set_order, only: [ :show, :charge, :cancel ]
  before_action :gray_background, only: [ :new, :show, :index ]

  # GET /orders
  def index
    @orders = current_user.orders.includes(:handyman).order(updated_at: :desc)
  end

  # GET /orders/:id
  def show
    fallback_redirect and return unless @order
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
      redirect_to [ :user, @order ], notice: t('.order_success')
    else
      gray_background
      set_address
      render :new
    end
  end

  # PUT /orders/:id/cancel
  def cancel
    fallback_redirect and return unless @order
    @order.canceler = current_user
    if @order.cancel && @order.save
      redirect_to [ :user, @order ], notice: t('.cancel_order_success')
    else
      redirect_to [ :user, @order ], notice: t('.cancel_order_failure')
    end
  end

  # GET /orders/:id/charge
  def charge
    if @order.valid_pingpp_charge? && !@order.payment_expired?
      render json: @order.pingpp_charge_json
    else
      render json: nil
    end
  end

  private

  def auth_client(url)
    user_wechat = UserWechatsController.wechat
    signature_options = user_wechat.jsapi_ticket.signature(url)
    {
      pingpp_charge: @order.pingpp_charge_json,
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

  def fallback_redirect
    redirect_to user_orders_url, notice: t('.request_failure')
  end

  def order_params
    params.require(:order).permit(:content, :arrives_at, :taxon_code,
                                  address_attributes: [ :code, :content ] )
  end
end
