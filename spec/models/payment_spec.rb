require 'rails_helper'

RSpec.describe Payment, type: :model, async: true do
  let(:order) { create :contracted_order, :payment, user: wechat_user }
  let(:wechat_user) { create :user, :wechat }
  let(:payment) { build :payment, order: order }
  let(:cash_payment) { build :cash_payment, order: order }
  let(:pingpp_wx_payment) { build :pingpp_wx_pub_payment, order: order }
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

    it 'completes wechat api payment' do
      payment.payment_method = 'wechat'
      expect(payment.checkout && payment.save).to eq true
      expect(payment.prepare && payment.save).to eq true
      expect(payment.complete).to eq true
      payment.save!
    end

    context 'on pingpp_wx_pub payment', :skip do
      before { payment.payment_method = 'pingpp_wx_pub' }
      it 'completes payment' do
        payment.checkout && payment.save!
        # p "PID = #{payment.id}"
        expect(payment.processing?).to eq true
        expect(payment.reload.aasm.current_state).to eq :processing
        state = wait_for(:pending) { payment.reload.aasm.current_state }
        expect(state).to eq :pending
        expect(payment.pingpp_charge.value).to be_present
      end

      it 'completes after failure due to network issue' do
        # TODO
      end
    end

    def wait_for(expected, period = 10, delta_time = 0.2)
      total_time = 0
      result = nil
      while(total_time < period)
        total_time += delta_time
        got = yield
        return expected if got == expected
        sleep delta_time
      end
      got
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
      let(:another_payment) { build :payment, order: order }

      it 'checkouts(and persists) a non-cash payment' do
        expect(payment.checkout && payment.save).to eq true
        expect(payment).to be_a Payment
        expect(payment).to be_persisted
        expect(payment.state).to eq 'processing'
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
        expect { another_payment.checkout }
          .to raise_error(TransitionFailure, message)
      end
    end

    describe 'prepare event' do
      # TODO
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
      it 'completes a pending (wechat-api) payment' do
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
