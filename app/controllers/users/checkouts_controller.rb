class Users::CheckoutsController < ApplicationController
  # POST /orders/:id/checkout
  def create
    in_cash? ? pay_in_cash : pay_in_wechat
  end

  # PUT/PATCH /orders/:id/checkout
  def update
    transition = serializable do
      return unless authorize_order(set_order)
      @payment = @order.ongoing_payment
      @payment.try(:check_and_transition!)
    end

    case transition
    when :failed
      set_notice(t '.payment_invalid')
    when :expired
      set_notice(t '.payment_expired')
    when :completed
      notify_wechat_accounts
      set_notice(t '.payment_success')
    else
      set_alert(t '.no_payment_result')
    end
    redirect_to [ :user, @order ]
  end

  private

  def changeset
    @order.assign_attributes(order_params)
    unless sync_from_user_total
      redirect_to [ :user, @order ], notice: t('.total_incorrect')
      return false
    end
    true
  end

  def serializable
    Order.serializable(max_retries: 2) { yield }
  end

  def sync_from_user_total
    options = {}
    options[:reset_bonus] = true if in_cash?
    @order.sync_from_user_total(options)
  end

  def in_cash?
    params[:p_method] == 'cash'
  end

  def notify_wechat_accounts
    id = @payment.id
    Payment::UserTemplates::AfterPaymentWorker.perform_async(id)
    Payment::HandymanTemplates::AfterPaymentWorker.perform_async(id)
  end

  def pay_in_cash
    transition = serializable do
      return unless authorize_order(set_order) && changeset
      set_payment('cash')
      @payment.may_complete? && @payment.complete && @payment.save
    end
    transition ? notify_wechat_accounts : set_alert(failure_message)
    redirect_to [ :user, @order ]
  end

  def pay_in_wechat
    return unless check_wechat_env
    transition = serializable do
      return unless authorize_order(set_order) && changeset
      set_payment('pingpp_wx_pub')
      @payment.may_checkout? && @payment.checkout && @payment.save
    end
    set_alert(failure_message) unless transition
    redirect_to [ :user, @order ]
  end

  def check_wechat_env
    return true if wechat_request? || debug_wechat?
    return false unless authorize_order(set_order)
    set_notice(t '.should_pay_in_wechat_client')
    redirect_to [ :user, @order ]
    false
  end

  def failure_message
    message = @order.errors.full_messages.join('；')
    message = t('.unknown_failure') if message.blank?
    "#{t('.payment_failure')}：#{message}"
  end

  def authorize_order(order)
    fallback_redirect unless order
    if order.user == current_user && (order.contracted? || order.payment?)
      true
    else
      fallback_redirect
    end
  end

  def set_order
    @order = Order.find_by(id: params[:id])
  end

  def fallback_redirect
    set_notice(t '.request_failure')
    redirect_to user_orders_url
    false
  end

  def set_payment(payment_method)
    @payment = @order.build_payment(payment_method: payment_method)
  end

  def order_params
    params.require(:order).permit(:user_total)
  end
end
