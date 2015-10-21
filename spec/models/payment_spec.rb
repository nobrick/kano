require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:order) { create :contracted_order, :payment }
  let(:payment) { build :payment, order: order }
  let(:cash_payment) { build :cash_payment, order: order }
  let(:pending_payment) { create :pending_payment, order: order }

  context 'From Payment.new' do
    before do
      payment.order = order
      payment.expires_at = 3.hours.since
      order.user_total = 300
      order.sync_from_user_total
    end
    let(:payment) { Payment.new }

    it 'completes cash payment' do
      payment.payment_method = 'cash'
      expect(payment.complete).to eq true
      payment.save!
    end

    it 'completes non-cash payment' do
      payment.payment_method = 'wechat'
      expect(payment.checkout && payment.save).to eq true
      expect(payment.process && payment.save).to eq true
      expect(payment.complete).to eq true
      payment.save!
    end
  end

  describe 'Order' do
    it 'has valid_payment' do
      payment.checkout && payment.save!
      expect(order.valid_payment).to eq payment
    end

    it 'has payments' do
      payment.checkout && payment.save!
      expect(order.payments).to eq [ payment ]
    end
  end

  describe 'state machine' do
    describe 'checkout event' do
      it 'checkouts(and persists) a non-cash payment' do
        expect(payment.checkout && payment.save).to eq true
        expect(payment).to be_a Payment
        expect(payment).to be_persisted
        expect(payment.state).to eq 'checkout'
        expect(payment.order.state).to eq 'payment'
      end

      it 'cannot checkout a cash payment' do
        message = "Event 'checkout' cannot transition from 'initial'"
        expect { cash_payment.checkout }
          .to raise_error(AASM::InvalidTransition, message)
        expect(cash_payment.initial?).to eq true
      end

      it 'cannot checkout more than one valid(not void or failed) payment' do
        payment.checkout && payment.save!

        message = 'Order valid payment already exists, set it void or failed first'
        expect { create :payment, order: order }
          .to raise_error(TransitionFailure, message)
      end
    end

    describe 'process event' do
      it 'cannot process cash payment' do
        expect { cash_payment.process }.to raise_error AASM::InvalidTransition
      end

      it 'processes non-cash payment' do
        payment.checkout && payment.save!

        expect(payment.process && payment.save).to eq true
        expect(payment.pending?).to eq true
      end
    end

    describe 'void event' do
      it 'cancels a payment' do
        payment.checkout && payment.save!

        expect(payment.void && payment.save).to eq true
        expect(order.payments).to eq [ payment ]
        expect(order.valid_payment).to be_nil
      end
    end

    describe 'fail event' do
      it 'fails a pending payment' do
        expect(pending_payment).to eq order.valid_payment
        expect(pending_payment.fail && pending_payment.save).to eq true
        expect(order.valid_payment).to be_nil
      end
    end

    describe 'complete event' do
      it 'completes a pending (non-cash) payment' do
        expect(pending_payment).to eq order.ongoing_payment
        expect(pending_payment.complete).to eq true

        expect(order.ongoing_payment).to eq pending_payment
        expect(order.valid_payment).to eq pending_payment
        expect(order.completed?).to eq true
        pending_payment.save!
        expect(order.ongoing_payment).to eq nil
        expect(order.valid_payment).to eq pending_payment
      end

      it 'completes a cash payment' do
        expect(cash_payment.initial?).to eq true
        expect(cash_payment.complete).to eq true

        expect(order.ongoing_payment).to eq nil
        expect(order.valid_payment).to eq nil
        expect(order.completed?).to eq true
        cash_payment.save!
        expect(order.ongoing_payment).to eq nil
        expect(order.valid_payment).to eq cash_payment
      end
    end
  end
end
