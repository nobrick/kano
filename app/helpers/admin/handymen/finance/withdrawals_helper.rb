module Admin::Handymen::Finance::WithdrawalsHelper
  def withdrawal_state(withdrawal)
    audit_state = withdrawal.audit_state
    if audit_state == 'unaudited'
      return 'unaudited'
    elsif audit_state == 'audited' && withdrawal.state == 'requested'
      return 'untransfered'
    elsif withdrawal.state == 'transferred'
      return 'transferred'
    elsif withdrawal.state == 'declined'
      return 'declined'
    elsif audit_state == 'abnormal'
      return 'abnormal'
    end
  end

  def render_admin_withdrawal_breadcrumb(handyman, withdrawal)
    case withdrawal_state(withdrawal)
    when 'declined'
      path = admin_handyman_finance_exceptions_path(handyman)
    else
      path = admin_handyman_finance_history_index_path(handyman)
    end
    info = [
      {
        text: "#{ handyman.full_or_nickname }主页(ID: #{ handyman.id })",
        path: admin_handyman_path(handyman)
      },
      {
        text: "财务信息",
        path: path
      },
      "提现"
    ]

    render_admin_breadcrumb(info)
  end
end
