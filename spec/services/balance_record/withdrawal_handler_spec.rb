require 'rails_helper'
require 'support/payment'
require 'support/timecop'

RSpec.describe BalanceRecord::WithdrawalHandler do
  let(:handyman) { create :handyman }
  let(:authorizer) { create :admin }

  it 'follows examples on GitHub Wiki' do
    on(1, 1) { pay }
    on(1, 2) { pay }
    on(1, 14) do
      expect { request_new }.to raise_error ActiveRecord::RecordInvalid
    end
    on(1, 30) { pay 2 }

    w1 = on(2, 7) do
      pay
      request_new
    end
    expect(w1.unfrozen_record).to eq last_record_on(1, 2)
    expect(w1.balance_record).to be_nil
    on(2, 8) { pay }
    on(2, 9) { transfer w1 }
    expect(w1.unfrozen_record).to eq last_record_on(1, 2)
    r1 = w1.balance_record
    expect(r1).to have_attributes({
      adjustment: -income_total_until(1, 2),
      online_income_total: income_total_until(2, 8),
      prev_online_income_total: r1.online_income_total,
      withdrawal_total: -r1.adjustment,
      prev_withdrawal_total: 0,
      bonus_sum_total: bonus_sum_total_until(2, 8),
      cash_total: 0
    })
    expect_correct_attributes_relationship_for(r1)

    on(2, 10) { pay }
    w2 = on(2, 14) { transfer(request_new) }
    expect(w2.unfrozen_record).to eq last_record_on(1, 30)
    r2 = w2.balance_record
    expect(r2).to have_attributes({
      adjustment: withdrawal_total_until(2, 10) - income_total_until(1, 30),
      online_income_total: income_total_until(2, 10),
      prev_online_income_total: r2.online_income_total,
      withdrawal_total: - r1.adjustment - r2.adjustment,
      prev_withdrawal_total: income_total_until(1, 2),
      bonus_sum_total: bonus_sum_total_until(2, 10),
      cash_total: 0
    })
    expect_correct_attributes_relationship_for(r2)

    on(2, 15) { pay }
    w3 = on(2, 28) { request_new }
    on(3, 1) { transfer w3 }
    expect(w3.unfrozen_record).to eq last_record_on(2, 14)
    r3 = w3.balance_record
    expect(r3).to have_attributes({
      adjustment: withdrawal_total_until(2, 15) - income_total_until(2, 14),
      online_income_total: income_total_until(2, 15),
      prev_online_income_total: r3.online_income_total,
      withdrawal_total: - [ r1, r2, r3 ].sum(&:adjustment),
      prev_withdrawal_total: r2.withdrawal_total,
      bonus_sum_total: bonus_sum_total_until(2, 15),
      cash_total: 0
    })
    expect_correct_attributes_relationship_for(r3)
  end

  def expect_correct_attributes_relationship_for(withdrawal_record)
    r = withdrawal_record
    expect(r.balance).to eq r.online_income_total - r.withdrawal_total
    expect(r.balance).to eq r.prev_balance + r.adjustment
    expect(r.online_income_total).to eq r.prev_online_income_total
    expect(r.withdrawal_total).to eq r.prev_withdrawal_total - r.adjustment
    expect(r.cash_total).to eq r.prev_cash_total
    expect(r.bonus_sum_total).to eq r.prev_bonus_sum_total
  end

  def request_new
    create :requested_withdrawal, handyman: handyman
  end

  def transfer(withdrawal)
    withdrawal.authorizer = authorizer
    withdrawal.transfer && withdrawal.save!
    withdrawal
  end

  def pay(orders_count = 1)
    create_paid_orders_for handyman, orders_count
  end

  def last_record_on(month, day)
    records_until(month, day).first
  end

  def income_total_until(month, day)
    records_until(month, day).for_payment.online.sum(:adjustment)
  end

  def withdrawal_total_until(month, day)
    - records_until(month, day).for_withdrawal.sum(:adjustment)
  end

  def bonus_sum_total_until(month, day)
      payment_records_until(month, day)
        .includes({ adjustment_event: :order })
        .map(&:adjustment_event)
        .sum(&:handyman_bonus_total)
  end

  def payment_records_until(month, day)
    records_until(month, day).for_payment.online
  end

  def records_until(month, day)
    handyman.balance_records.until(on month, day)
  end
end
