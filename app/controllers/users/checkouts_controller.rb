class Users::CheckoutsController < ApplicationController
  before_action :authenticate_completed_user
  before_action :set_order, only: [ :create ]
  before_action :check_order_permission, only: [ :create ]

  # POST /orders/:id/checkout
  def create
    @order.assign_attributes(order_params)
    @order.user_promo_total = 0
    @order.handyman_bonus_total = 0
    @order.sync_from_user_total
    if params[:p_method] == 'cash'
      pay_in_cash
    else
      redirect_to user_orders_url, notice: '参数错误' and return false
    end
  end

  private

  def pay_in_cash
    set_payment('cash')
    raise unless @payment.checkout!
    if @payment.complete!
      redirect_to user_orders_url, notice: '支付成功'
    else
      redirect_to user_orders_url, notice: '支付失败'
    end
  end

  def set_order
    @order = Order.find_by(id: params[:id])
  end

  def check_order_permission
    if @order.nil? || @order.user != current_user || !(@order.contracted?)
      redirect_to user_orders_url, notice: '请求失败' and return false
    else
      true
    end
  end

  def set_payment(payment_method)
    # Do not use `orders.payment.build` for payment creation
    @payment = Payment.new
    @payment.order = @order
    @payment.expires_at = 3.hours.since
    @payment.payment_method = payment_method
  end

  def order_params
    params.require(:order).permit(:user_total)
  end
end
