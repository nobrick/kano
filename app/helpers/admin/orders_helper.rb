module Admin::OrdersHelper
  def admin_user_info(order)
    user = order.user
    last_row = order.did_complete?

    if user.nickname.blank?
      nickname = "(查看详情)"
    else
      nickname = user.nickname
    end

    {
      title: "用户信息",
      items: [
        { name: "编号", value: "#{ user.id }" },
        { name: "昵称", value: "#{ link_to(capture { nickname }, admin_user_path(user))}" },
        { name:"姓名", value: "#{ capture { user.name } }" },
        { name: "联系方式", value: "#{ user.readable_phone_number }" }
      ],
      last_row: last_row?(order, :profile)
    }
  end

  def admin_handyman_info(order)
    handyman = order.handyman
    if handyman.nickname.blank?
      nickname = "(查看详情)"
    else
      nickname = handyman.nickname
    end

    {
      title: "管家信息",
      items: [
        { name: "编号", value: "#{ handyman.id }" },
        { name: "昵称", value: "#{ link_to(capture { nickname }, admin_handyman_path(handyman)) }" },
        { name: "姓名" , value: "#{ capture { handyman.name } }" },
        { name: "联系方式", value: "#{ handyman.readable_phone_number }" }
      ],
      last_row: last_row?(order, :profile)
    }
  end

  def admin_order_content(order)
    arrives_time = order.arrives_at
    arrives_time = arrives_time.blank? ? "" : I18n.l(arrives_time, format: :long)
    {
      title: "维修信息",
      items: [
        { name: "维修项目", value: "#{ order.taxon_name }" },
        { name: "维修内容", value: "#{ capture { order.content } }" },
        { name: "维修地址", value: "#{ capture { order.address.try :full_content } }" },
        { name: "预约时间", value: "#{ arrives_time }" }

      ]
    }
  end

  def admin_order_rate(order)
    {
      title: "评价详情",
      items: [
        { name: "评分", value: "#{ order.rating }" },
        { name: "评价", value: "#{ capture { order.rating_content } }" }
      ]
    }
  end

  def admin_order_report(order)
    {
      title: "投诉信息",
      items: [
        { name: "投诉类型", value: "#{ order.report_type }" },
        { name: "投诉内容", value: "#{ capture { order.report_content } }" }
      ]
    }
  end

  def admin_order_cancel(order)
    {
      title: "订单取消详情",
      items: [
        { name: "取消者 ID", value: "#{ order.canceler.id }" },
        { name: "取消者", value: "#{ capture { order.canceler.full_or_nickname } }" },
        { name: "取消理由", value: "#{ capture { order.cancel_reason } }" }
      ],
      last_row: true
    }
  end

  def admin_user_payment(order)
    {
      title: "用户支付信息",
      items: [
        { name: "订单价格", value: "#{ order.user_total }" },
        { name: "- 价格优惠", value: "#{ order.user_promo_total }" },
        { name: "实际支付", value: "#{ order.payment_total }" }],
      payment_item: true,
      last_row: true
    }

  end

  def admin_handyman_payment(order)
    {
      title: "管家收益信息",
      items: [
        { name: "订单价格", value: "#{ order.user_total }" },
        { name: "- 价格优惠", value: "#{ order.user_promo_total }" },
        { name: "+ 奖励金额", value: "#{ order.handyman_bonus_total }" },
        { name: "实得金额", value: "#{ order.handyman_total }" }],
      payment_item: true,
      last_row: true
    }
  end

  def could_cancel?(order)
   !order.did_complete? && !order.did_cancel?
  end

  private

  def last_row?(order, info_block)
    case info_block
    when :profile
      if !order.did_complete? && !order.did_cancel?
        true
      else
        false
      end
    else
      true
    end
  end
end
