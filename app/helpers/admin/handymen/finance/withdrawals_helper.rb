module Admin::Handymen::Finance::WithdrawalsHelper
  def withdrawal_state(withdrawal)
    audit_state = withdrawal.audit_state
    if audit_state == 'unaudited'
      return { :css_class => 'label-warning', :value => '等待审核' }
    elsif audit_state == 'audited' && withdrawal.state == 'requested'
      return { :css_class => 'label-warning', :value => '等待转账' }
    elsif audit_state == 'unaudited'
      return { :css_class => 'label-danger', :value => '审核未通过' }
    elsif withdrawal.state == 'declined'
      return { :css_class => 'label-danger', :value => '转账失败' }
    end
  end

  def waiting_for_transfer?(withdrawal)
    audit_state = withdrawal.audit_state
    state = withdrawal.state
    audit_state == 'audited' && state == 'requested'
  end

  def waiting_for_audit?(withdrawal)
    withdrawal.audit_state == 'unaudited'
  end
end
