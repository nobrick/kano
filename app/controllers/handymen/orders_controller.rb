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
      redirect_to handyman_contract_url(@order), notice: '接单成功'
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
    return false unless authenticate_handyman_order

    case @order.state
    when 'requested' then true
    else redirect_to handyman_contract_url(@order) and return false
    end
  end
end
