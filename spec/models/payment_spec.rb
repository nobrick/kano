require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:order) { create :contracted_order, :payment }
  let(:payment) { build :payment, order: order }
  let(:cash_payment) { build :cash_payment, order: order }
  let(:pending_payment) { create :pending_payment, order: order }

  describe 'Order' do
    it 'has valid_payment' do
      payment.checkout!
      expect(order.valid_payment).to eq payment
    end

    it 'has payments' do
      payment.checkout!
      expect(order.payments).to eq [ payment ]
    end
  end

  describe 'state machine' do
    describe 'checkout event' do
      it 'checkouts(and persists) a payment' do
        expect(payment.checkout!).to eq true
        expect(payment).to be_a Payment
        expect(payment).to be_persisted
        expect(payment.state).to eq 'checkout'
        expect(payment.order.state).to eq 'payment'
      end

      it 'cannot checkout more than one valid(not void or failed) payment' do
        payment.checkout!
        message = 'Order valid payment already exists, set it void or failed first'
        expect { create :payment, order: order }
          .to raise_error(ConcernsForAASM::TransitionFailure, message)
      end
    end

    describe 'process event' do
      it 'cannot process cash payment' do
        cash_payment.checkout!
        message = "Event 'process' cannot transition from 'checkout'"
        expect { cash_payment.process! }
          .to raise_error(AASM::InvalidTransition, message)
      end

      it 'processes non-cash payment' do
        payment.checkout!
        expect(payment.process!).to eq true
        expect(payment.pending?).to eq true
      end
    end

    describe 'void event' do
      it 'cancels a payment' do
        payment.checkout!
        expect(payment.void!).to eq true
        expect(order.payments).to eq [ payment ]
        expect(order.valid_payment).to be_nil
      end
    end

    describe 'fail event' do
      it 'fails a pending payment' do
        expect(pending_payment).to eq order.valid_payment
        expect(pending_payment.fail!).to eq true
        expect(order.valid_payment).to be_nil
      end
    end

    describe 'complete event' do
      it 'completes a pending (non-cash) payment' do
        expect(pending_payment).to eq order.ongoing_payment
        expect(pending_payment.complete!).to eq true
        expect(order.ongoing_payment).to eq nil
        expect(order.valid_payment).to eq pending_payment
        expect(order.completed?).to eq true
      end

      it 'completes a contracted cash payment' do
        cash_payment.checkout!
        expect(cash_payment).to eq order.ongoing_payment
        expect(cash_payment.complete!).to eq true
        expect(order.ongoing_payment).to eq nil
        expect(order.valid_payment).to eq cash_payment
        expect(order.completed?).to eq true
      end
    end
  end
end
