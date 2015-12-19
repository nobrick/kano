# For handyman managing his own received orders
class Handymen::OrderContractsController < ApplicationController
  before_action :authenticate_completed_handyman
  before_action :gray_background, only: [ :show ]

  # GET /contracts
  def index
    @orders = Order.includes(:user, :address)
      .where(handyman: current_handyman)
      .order(updated_at: :desc)
  end

  # GET /contracts/:id
  def show
    @order = Order.find(params[:id])
    check_order_permission
  end

  private

  def check_order_permission
    unauthorized_options = { alert: t('.order_not_exist') }
    return false unless authenticate_handyman_order(unauthorized_options)

    case @order.state
    when 'requested' then redirect_to [ :handyman, @order ] and return false
    else true
    end
  end
end
