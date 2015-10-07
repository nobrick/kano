class Handymen::OrdersController < ApplicationController
  before_action :authenticate_completed_handyman
  before_action :set_order, only: [ :show, :update ]
  before_action :check_order_permission, only: [ :show, :update ]

  # GET /orders
  def index
    @orders = Order.where(state: 'requested').order(created_at: :desc)
  end

  # GET /orders/:id
  def show
  end

  # POST /orders
  def update
    @order.handyman = current_handyman
    if @order.contract!
      redirect_to handyman_orders_url, notice: '接单成功'
    else
      redirect_to handyman_orders_url,
        alert: "接单失败: #{@order.errors.full_messages.join('；')}"
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def check_order_permission
    if @order.handyman.present? && @order.handyman != current_handyman
      redirect_to handyman_orders_url, alert: '请求失败，订单可能已经被别人抢走'
      return false
    end

    case @order.state
    when 'requested'
      true
    else
      # TODO Redirect orders without :requested state to other controller actions.
      redirect_to handyman_orders_url, notice: 'TODO'
      false
    end
  end
end
