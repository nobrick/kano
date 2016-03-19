module Admin::Orders::HistoryHelper
  def order_history_for(order)
    if %{ requested contracted payment completed rated }.include?(order.state)
      normal_history_for(order)
    elsif canceled?
      cancel_history_for(order)
    else
      report_history_for(order)
    end
  end

  private

  def normal_history_for(order)
    {
      "request" => order.created_at,
      "contract" => order.contracted_at,
      "complete" => order.completed_at,
      "rate" => order.rated_at
    }
  end

  def cancel_history_for(order)
    return unless order.canceled?

    if order.did_contract?
      {
        "request" => order.created_at,
        "contract" => order.contracted_at,
        "cancel" => order.canceled_at
      }
    else
      {
        "request" => order.created_at,
        "cancel" => order.canceled_at
      }
    end
  end

  def report_history_for(order)
    return unless order.rated?

    basic_history = {
      "request" => order.created_at,
      "contract" => order.contracted_at,
    }
    if did_rate?
      basic_history["complete"] = order.completed_at
      basic_history["rate"] = order.rated_at
    elsif did_complete?
      basic_history["complete"] = order.completed_at
    end

    basic_history
  end
end
