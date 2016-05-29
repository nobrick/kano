# For handyman receiving orders for public user requests
class Handymen::OrdersController < ApplicationController
  before_action :authenticate_completed_handyman
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
    return unless changeset
    @pricing = @order.pricing
  end

  # POST /orders
  def update
    if contract_and_save { return unless changeset }
      notify_wechat_accounts
      redirect_to handyman_contract_url(@order), notice: t('.update_success')
    else
      reasons = @order.errors.full_messages.join('；')
      alert = t('.update_failure', reasons: reasons)
      redirect_to handyman_orders_url, alert: alert
    end
  end

  private

  def contract_and_save
    opts = { whiny_transition: false }
    Order.serializable_trigger(:contract, :save, opts) do
      yield
      @order
    end
  end

  def changeset
    fallback_redirect and return false unless set_order
    return false unless check_order_permission
    set_handyman_and_bonus
    true
  end

  def set_order
    @order = Order.find_by(id: params[:id])
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

  def fallback_redirect
    redirect_to handyman_orders_url, notice: t('.request_failure')
  end
end
