# For handyman receiving orders for public user requests
class Handymen::OrdersController < ApplicationController
  before_action :authenticate_completed_handyman
  before_action :set_order, only: [ :show, :update ]
  before_action :check_order_permission, only: [ :show, :update ]
  before_action :gray_background, only: [ :show ]

  # GET /orders
  def index
    codes = current_handyman.taxon_codes
    @orders = Order.where(state: 'requested', taxon_code: codes).order(created_at: :desc)
  end

  # GET /orders/:id
  def show
  end

  # POST /orders
  def update
    @order.handyman = current_handyman
    if @order.contract && @order.save
      redirect_to handyman_contract_url(@order), notice: t('.update_success')
    else
      redirect_to handyman_orders_url,
        alert: t('.update_failure', reasons: @order.errors.full_messages.join('；'))
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def check_order_permission
    unauthorized_options = { alert: t('.order_unauthorized') }
    return false unless authenticate_handyman_order(unauthorized_options)

    case @order.state
    when 'requested' then true
    else redirect_to handyman_contract_url(@order) and return false
    end
  end
end
