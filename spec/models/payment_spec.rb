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

    context 'On pingpp_wx_pub payment' do
      let(:paid_hash) { { 'order_no' => order_no, 'paid' => true } }
      let(:unpaid_hash) { { 'order_no' => order_no, 'paid' => false } }
      let(:order_no) { payment.order.id }

      before do
        payment.payment_method = 'pingpp_wx_pub'
        payment.checkout && payment.save!
      end

      it '#checkout into :processing state' do
        expect(payment.processing?).to eq true
        expect(payment.reload.aasm.current_state).to eq :processing
      end

      it '#save_with_prepare! into :pending state with charge' do
        allow(Pingpp::Charge).to receive(:create).and_return(unpaid_hash)
        payment.save_with_prepare!
        expect(payment.pingpp_charge_json).to be_present
        expect(payment.reload.aasm.current_state).to eq :pending
      end

      describe '#check_and_complete!' do
        it 'gets into :completed state if paid' do
          allow(Pingpp::Charge).to receive(:create).and_return(paid_hash)
          payment.save_with_prepare!
          payment.check_and_complete!
          expect(payment.reload.aasm.current_state).to eq :completed
        end

        it 'stays :pending state if not paid' do
          allow(Pingpp::Charge).to receive(:create).and_return(unpaid_hash)
          payment.save_with_prepare!
          payment.check_and_complete!
          expect(payment.reload.aasm.current_state).to eq :pending
        end

        it 'gets into :completed by retrieving new charge object' do
          allow(Pingpp::Charge).to receive(:create).and_return(unpaid_hash)
          allow(Pingpp::Charge).to receive(:retrieve).and_return(unpaid_hash)
          payment.save_with_prepare!

          # Call #retrieve_pingpp_charge instead of caching version every time.
          payment.pingpp_retrieve_min_interval = -1

          payment.check_and_complete!
          expect(payment.reload.aasm.current_state).to eq :pending

          allow(Pingpp::Charge).to receive(:retrieve).and_return(paid_hash)
          payment.check_and_complete!
          expect(payment.reload.aasm.current_state).to eq :completed
        end
      end
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

  describe 'State machine' do
    describe 'Checkout event' do
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

    describe 'Void event' do
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
