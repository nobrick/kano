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
end
