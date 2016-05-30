class Users::Orders::ResendsController < ApplicationController
  # PUT /orders/:id/resend
  def update
    opts = { whiny_transition: false }
    transition = Order.serializable_trigger(:cancel, :save, opts) do
      fallback_redirect and return unless set_order
      @order.tap { |o| o.canceler = current_user }
    end

    if transition
      resends = @order.attributes.select { |k| k.in? %w{ content taxon_code } }
      notice = t('.resend_order_success')
      redirect_to new_user_order_path(resend: resends), notice: notice
    else
      redirect_to [ :user, @order ], notice: t('.resend_order_failure')
    end
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id])
    if @order.try(:user) == current_user
      @order
    else
      @order = nil
    end
  end

  def fallback_redirect
    redirect_to user_orders_url, notice: t('^request_failure')
  end
end
