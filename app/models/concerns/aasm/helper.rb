module AASM::Helper
  extend ActiveSupport::Concern

  def to?(states_or_state)
    if states_or_state.is_a? Symbol
      aasm.to_state == states_or_state
    else
      states_or_state.any? { |s| aasm.to_state == s }
    end
  end
end
