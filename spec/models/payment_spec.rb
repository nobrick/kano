require 'rails_helper'
require 'support/payment'

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
      payment.expires_at = expires_at
      order.user_total = 300
      order.sync_from_user_total
    end
    let(:payment) { Payment.new }
    let(:expires_at) { 3.hours.since }

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
      Charge = Pingpp::Charge
      let(:unpaid_hash) { unpaid_hash_for(payment, expired: pingpp_charge_expired) }
      let(:paid_hash) { paid_hash_for(payment) }
      let(:pingpp_charge_expired) { false }

      before do
        payment.payment_method = 'pingpp_wx_pub'
        payment.checkout && payment.save!
        allow(Charge).to receive(:create).and_return(unpaid_hash)
      end

      it 'checkouts into :processing state' do
        expect(payment.processing?).to eq true
        expect(payment.reload.aasm.current_state).to eq :processing
      end

      describe '#save_with_prepare!' do
        it 'transitions into :pending state with charge' do
          payment.save_with_prepare!
          expect(payment.pingpp_charge_json).to be_present
          expect(payment.reload.aasm.current_state).to eq :pending
        end
      end

      describe '#check_and_complete!' do
        it 'gets into :completed state if paid' do
          payment.save_with_prepare!
          allow(Charge).to receive(:retrieve).and_return(paid_hash)
          payment.check_and_complete!(fetch_latest: true)
          expect(payment.reload.aasm.current_state).to eq :completed
        end

        it 'does not complete immediately because of caching when paid' do
          payment.save_with_prepare!
          allow(Charge).to receive(:retrieve).and_return(paid_hash)
          payment.check_and_complete!
          expect(payment.reload.aasm.current_state).to eq :pending
        end

        it 'stays :pending state if not paid' do
          payment.save_with_prepare!
          payment.check_and_complete!
          expect(payment.reload.aasm.current_state).to eq :pending
        end

        it 'gets into :completed by retrieving new charge object' do
          allow(Charge).to receive(:retrieve).and_return(unpaid_hash)
          payment.save_with_prepare!
          payment.check_and_complete!(fetch_latest: true)
          expect(payment.reload.aasm.current_state).to eq :pending

          allow(Charge).to receive(:retrieve).and_return(paid_hash)
          payment.check_and_complete!(fetch_latest: true)
          expect(payment.reload.aasm.current_state).to eq :completed
        end
      end

      describe '#expire' do
        shared_examples_for 'expiration' do
          it 'does not expire if not in pending state' do
            expect(payment.expired?).to eq false
          end

          it 'expires in pending state' do
            payment.save_with_prepare!
            expect(payment.expired?).to eq true
          end
        end

        context 'when current time is over time_expire on fetched object' do
          let(:pingpp_charge_expired) { true }
          it_behaves_like 'expiration'
        end

        context 'when current time is over expires_at attribute' do
          let(:expires_at) { 1.second.ago }
          it_behaves_like 'expiration'
        end
      end

      describe '#check_and_expire!' do
        context 'When payment is not in pending state' do
          let(:pingpp_charge_expired) { true }
          let(:expires_at) { 1.second.ago }

          it 'returns false' do
            expect(payment.processing?).to eq true
            expect(payment.check_and_expire!).to eq false
          end
        end

        context 'When payment is pending but not expired' do
          it 'returns false' do
            prepare_payment!(payment)
            expect(payment.pending?).to eq true
            expect(payment.expired?).to eq false
            expect(payment.check_and_expire!).to eq false
          end
        end

        context 'When pending payment is pending and expired' do
          before do
            prepare_payment!(payment, expired: true)
            allow(Charge).to receive(:retrieve).and_return(unpaid_hash)
          end

          it 'trys to #check_and_complete with :fetch_latest on' do
            expect(payment.pending?).to eq true
            expect(payment.expired?).to eq true
            expect(payment).to receive(:check_and_complete!).with(fetch_latest: true)
            payment.check_and_expire!
          end

          context 'When the lastest fetch is not paid' do
            it 'expires the payment'  do
              expect(payment.pending?).to eq true
              payment.check_and_expire!
              expect(payment.reload.void?).to eq true
            end

            it 'returns true' do
              expect(payment.check_and_expire!).to eq true
            end
          end

          context 'When the lastest fetch is paid' do
            before do
              allow(Charge).to receive(:retrieve).and_return(paid_hash)
            end

            it 'completes payment' do
              payment.check_and_expire!
              expect(payment.reload.completed?).to eq true
            end

            it 'returns false' do
              expect(payment.check_and_expire!).to eq false
            end
          end
        end
      end

      describe '#check_and_fail' do
        let(:invalid_charge) { unpaid_hash.merge(order_no: 'INVALID') }

        context 'When in a state other than processing and pending' do
          before { complete_payment!(prepare_payment!(payment)) }

          it 'returns false' do
            expect(payment.completed?).to eq true
            expect(payment.check_and_fail!).to eq false
          end
        end

        shared_examples_for 'check and fail when charge is invalid' do
          before { allow(Charge).to receive(:create).and_return(unpaid_hash) }

          it 'retries to create new pingpp charge by default' do
            expect(payment.valid_pingpp_charge?).to eq false
            expect(Charge).to receive(:create)
            expect(payment.check_and_fail!).to eq false
          end

          context 'After retry success' do
            it 'sets valid charge' do
              expect { payment.check_and_fail! }
                .to change(payment, :valid_pingpp_charge?).to true
            end

            it 'remains / transitions to pending state' do
              payment.check_and_fail!
              expect(payment.pending?).to eq true
            end

            it 'returns false' do
              expect(payment.check_and_fail!).to eq false
            end
          end

          context 'After retry failure' do
            before { allow(Charge).to receive(:create).and_return(invalid_charge) }

            it 'fails the payment'  do
              expect { payment.check_and_fail! }.to change(payment, :failed?).to true
            end

            it 'returns true' do
              expect(payment.check_and_fail!).to eq true
            end
          end
        end

        context 'When processing' do
          it 'charge is invalid in this state' do
            expect(payment.processing?).to eq true
            expect(payment.valid_pingpp_charge?).to eq false
          end

          it_behaves_like 'check and fail when charge is invalid'
        end

        context 'When pending' do
          before { prepare_payment!(payment) }

          context 'When charge is valid' do
            it 'returns false' do
              expect(payment.pending?).to eq true
              expect(payment.check_and_fail!).to eq false
            end
          end

          context 'When charge is invalid' do
            before { payment.send(:set_pingpp_charge, invalid_charge) }

            it_behaves_like 'check and fail when charge is invalid'
          end
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

        message = 'Invalid payment'
        expect { another_payment.checkout }
          .to raise_error(TransitionFailure, message)
      end
    end

    describe 'Cancel event' do
      it 'cancels a payment' do
        payment.checkout && payment.save!
        expect(payment.cancel && payment.save).to eq true
        expect(order.payments).to eq [ payment ]
        expect(order.valid_payment).to be_nil
      end
    end

    describe 'Flunk event' do
      it 'fails a processing payment' do
        expect(pending_payment).to eq order.valid_payment
        expect(pending_payment.flunk && pending_payment.save).to eq true
        expect(order.valid_payment).to be_nil
      end
    end

    describe 'Complete event' do
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
