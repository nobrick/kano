# For handyman managing his own received orders
class Handymen::OrderContractsController < ApplicationController
  before_action :authenticate_completed_handyman

  # GET /contracts
  def index
    @orders = Order.where(handyman: current_handyman)
      .order(created_at: :desc)
  end

  # GET /contracts/:id
  def show
    @order = Order.find(params[:id])
    check_order_permission
  end

  private

  def check_order_permission
    return false unless authenticate_handyman_order

    case @order.state
    when 'requested' then redirect_to [ :handyman, @order ] and return false
    else true
    end
  end
end