class Order::HandymanBonusAgent
  def self.set_handyman_bonus(order, strategy = nil, options = {})
    strategy ||= :normal
    number = options.fetch(:number_for_extra_bonus, 80)

    if order.handyman.orders_paid_by_pingpp.completed_in_month.count < number
      order.handyman_bonus_total = 5
    else
      order.handyman_bonus_total = 10
    end

    order
  end
end
