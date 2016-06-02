class Handymen::Contracts::ResendsController < ApplicationController
  # PUT /contracts/:id/resend
  def update
    Order.serializable do
      fallback_redirect and return unless set_order && @order.may_cancel?
      @order.canceler = current_handyman
      raise ActiveRecord::Rollback unless @order.cancel && @order.save
      if set_new_order(@order).request && @new_order.save
        flash[:notice] = t('.resend_order_success')
      else
        raise ActiveRecord::Rollback
      end
    end

    flash[:notice] ||= t('.resend_order_failure')
    redirect_to handyman_contract_url(@order)
  end

  private

  def set_new_order(order)
    attributes = order.attributes.select do |key|
      key.in? %w{ content arrives_at taxon_code }
    end
    @new_order = order.user.orders.build(attributes)
    @new_order.address_attributes = @order.address.attribute_hash
    @new_order.ignores_arrives_at_validation = true
    @new_order
  end

  def set_order
    @order = Order.find_by(id: params[:id])
    if @order.try(:handyman) == current_handyman
      @order
    else
      @order = nil
    end
  end

  def fallback_redirect
    redirect_to handyman_contracts_url, notice: t('^request_failure')
  end
end
