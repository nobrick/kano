# For handyman receiving orders for public user requests
class Handymen::OrdersController < ApplicationController
  before_action :authenticate_completed_handyman
  before_action :set_order, only: [ :show, :update ]
  before_action :check_order_permission, only: [ :show, :update ]
  before_action :set_handyman_and_bonus, only: [ :show, :update ]
  before_action :gray_background, only: [ :show, :index ]

  # GET /orders
  def index
    codes = current_handyman.taxon_codes
    @orders = Order.includes(:user, :address)
      .where(state: 'requested', taxon_code: codes)
      .order(created_at: :desc)
      .page(params[:page]).per(12)
  end

  # GET /orders/:id
  def show
    @pricing = @order.pricing
  end

  # POST /orders
  def update
    if @order.contract && @order.save
      notify_wechat_accounts
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

  def set_handyman_and_bonus
    @order.handyman = current_handyman
    Order::HandymanBonusAgent.set_handyman_bonus(@order)
  end

  def notify_wechat_accounts
    Payment::UserTemplates::AfterContractWorker.perform_async(@order.id)
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
