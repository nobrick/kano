class Users::CheckoutsController < ApplicationController
  before_action :set_order, only: [ :create, :update ]
  before_action :check_order_permission, only: [ :create, :update ]

  # POST /orders/:id/checkout
  def create
    @order.assign_attributes(order_params)
    unless sync_from_user_total
      redirect_to [ :user, @order ],
        notice: t('.total_incorrect') and return false
    end
    in_cash? ? pay_in_cash : pay_in_wechat
  end

  # PUT/PATCH /orders/:id/checkout
  def update
    @payment = @order.ongoing_payment
    case @payment.try(:check_and_transition!)
    when :failed
      redirect_to [ :user, @order ], notice: t('.payment_invalid')
    when :expired
      redirect_to [ :user, @order ], notice: t('.payment_expired')
    when :completed
      notify_wechat_accounts
      redirect_to [ :user, @order ], notice: t('.payment_success')
    else
      redirect_to [ :user, @order ], alert: t('.no_payment_result')
    end
  end

  private

  def sync_from_user_total
    options = {}
    options[:reset_bonus] = true if in_cash?
    @order.sync_from_user_total(options)
  end

  def in_cash?
    params[:p_method] == 'cash'
  end

  def notify_wechat_accounts
    Payment::UserTemplateWorker.perform_async(:complete_order, @payment.id)
  end

  def pay_in_cash
    set_payment('cash')
    if @payment.complete && @payment.save
      notify_wechat_accounts
      redirect_to [ :user, @order ], notice: t('.payment_success')
    else
      redirect_to [ :user, @order ], alert: failure_message
    end
  end

  def pay_in_wechat
    unless wechat_request? || debug_wechat?
      message = t('.should_pay_in_wechat_client')
      redirect_to [ :user, @order ], notice: message and return false
    end

    set_payment('pingpp_wx_pub')
    if @payment.checkout && @payment.save
      redirect_to [ :user, @order ]
    else
      redirect_to [ :user, @order ], alert: failure_message
    end
  end

  def failure_message
    message = @order.errors.full_messages.join('；')
    message = t('.unknown_failure') if message.blank?
    "#{t('.payment_failure')}：#{message}"
  end

  def set_order
    @order = Order.find_by(id: params[:id])
  end

  def check_order_permission
    if @order.nil? || @order.user != current_user || !(@order.contracted? || @order.payment?)
      redirect_to user_orders_url, notice: t('.request_failure') and return false
    else
      true
    end
  end

  def set_payment(payment_method)
    @payment = @order.build_payment(payment_method: payment_method)
  end

  def order_params
    params.require(:order).permit(:user_total)
  end
end
