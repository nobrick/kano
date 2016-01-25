require 'rails_helper'

RSpec.describe BalanceRecord, type: :model do
  let(:record) { payment.balance_record }
  let(:cash_record) { cash_payment.balance_record }
  let(:payment) { create :completed_payment, order: order1 }
  let(:cash_payment) { create :completed_payment, :cash, order: order2 }
  let(:order1) { create :contracted_order, :payment, handyman: handyman }
  let(:order2) { create :contracted_order, :payment, handyman: handyman, bonus_amount: 0 }
  let(:handyman) { create :handyman }

  describe 'Payment' do
    before do
      payment.order = order1
      payment.expires_at = 3.hours.since
      order1.user_total = 300
    end
    let(:payment) { Payment.new }

    it 'creates balance record on cash payment' do
      payment.order.sync_from_user_total(reset_bonus: true)
      payment.payment_method = 'cash'
      payment.complete
      expect { payment.save! }.to change(BalanceRecord, :count).by 1
      expect(payment.balance_record).to be_persisted
    end

    it 'creates balance record on non-cash payment' do
      payment.order.sync_from_user_total
      payment.payment_method = 'wechat'
      payment.checkout && payment.save!
      payment.prepare && payment.save!
      payment.complete
      expect { payment.save! }.to change(BalanceRecord, :count).by 1
      expect(payment.balance_record).to be_persisted
    end
  end

  it 'creates balance record by test helpers' do
    expect(record).to be_a BalanceRecord
    expect(record).to be_persisted
    expect(cash_record).to be_a BalanceRecord
    expect(cash_record).to be_persisted
  end

  it 'keeps associations on handyman' do
    record
    expect(handyman.latest_balance_record).to eq record
    expect(handyman.balance_records).to eq [ record ]

    cash_record
    handyman.reload
    expect(handyman.balance_records).to eq [ cash_record, record ]
    expect(handyman.latest_balance_record).to eq cash_record
  end

  it 'is readonly once created' do
    expect { record.save! }.to raise_error ActiveRecord::ReadOnlyRecord
  end

  context 'With non-cash payment' do
    let(:event) { record.event }

    it 'keeps correct attributes' do
      expect(event).to eq payment
      expect(record.owner).to eq event.handyman
      expect(record.in_cash?).to eq false
      expect(record.previous_balance).to eq 0
      expect(record.balance).to eq event.handyman_total
      expect(record.previous_cash_total).to eq 0
      expect(record.cash_total).to eq 0
      expect(record.adjustment).to eq event.handyman_total
      expect(record.base_adjustment).to eq event.user_total
      expect(record.base_balance).to eq event.user_total
      expect(record.previous_base_balance).to eq 0
    end
  end

  context 'With cash payment' do
    let(:record) { cash_record }
    let(:event) { cash_record.event }

    it 'keeps correct attributes for cash payment' do
      expect(event).to eq cash_payment
      expect(record.owner).to eq event.handyman
      expect(record.in_cash?).to eq true
      expect(record.previous_balance).to eq 0
      expect(record.balance).to eq 0
      expect(record.previous_cash_total).to eq 0
      expect(record.cash_total).to eq event.handyman_total
      expect(record.adjustment).to eq event.handyman_total
      expect(record.base_adjustment).to eq event.user_total
      expect(record.base_balance).to eq 0
      expect(record.previous_base_balance).to eq 0

      expect(event.user_total).to eq event.handyman_total
      expect(event.handyman_bonus_total).to eq 0
    end
  end

  it 'keeps correct attributes for randomized payment seeds' do
    events = []
    5.times do |i|
      event = random_payment
      previous_events = events.dup
      events << event
      record = event.balance_record

      expect(record.in_cash?).to eq event.in_cash?
      expect(record.owner).to eq event.handyman
      expect(record.adjustment).to eq event.handyman_total
      expect(record.base_adjustment).to eq event.user_total

      handyman.reload
      expect(record).to eq handyman.latest_balance_record
      expect(events.map(&:balance_record))
        .to match_array handyman.balance_records

      previous_in_cash_events = previous_events.select(&:in_cash?)
      previous_non_in_cash_events = previous_events.reject(&:in_cash?)
      previous_balance = previous_non_in_cash_events
        .map(&:handyman_total).reduce(0, :+)
      previous_base_balance = previous_non_in_cash_events
        .map(&:user_total).reduce(0, :+)
      previous_cash_total = previous_in_cash_events
        .map(&:handyman_total).reduce(0, :+)

      balance = previous_balance
      base_balance = previous_base_balance
      cash_total = previous_cash_total

      if record.in_cash?
        cash_total += event.handyman_total
      else
        balance += event.handyman_total
        base_balance += event.user_total
      end

      expect(record.previous_balance).to eq previous_balance
      expect(record.balance).to eq balance
      expect(record.previous_cash_total).to eq previous_cash_total
      expect(record.cash_total).to eq cash_total
      expect(record.previous_base_balance).to eq previous_base_balance
      expect(record.base_balance).to eq base_balance

      if record.in_cash?
        expect(record.adjustment).to eq record.base_adjustment
      else
        expect(record.adjustment).to eq record.base_adjustment + record.event.handyman_bonus_total
      end
    end
  end

  def random_payment
    if rand(0..1) > 0
      order = create :contracted_order, :payment, handyman: handyman, bonus_amount: 0
      create :completed_payment, :cash, order: order
    else
      order = create :contracted_order, :payment, handyman: handyman
      create :completed_payment, order: order
    end
  end
end
