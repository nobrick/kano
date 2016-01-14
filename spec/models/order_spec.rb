require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:user) { create :user }
  let(:handyman) { create :handyman }
  let(:address_hash) { { address_attributes: attributes_for(:address) } }
  let(:order_attrs) { attributes_for(:order).merge(address_hash) }
  let(:order) { Order.new(order_attrs).tap { |o| o.user = user } }
  let(:order_requested) { create :requested_order }
  let(:order_contracted) { create :contracted_order }

  it 'creates an order' do
    expect(order_requested).to be_persisted
    expect(order_requested.user).to be_persisted
  end

  describe 'arrives_at field' do
    it 'fails if invalid' do
      order.assign_attributes(arrives_at: 1.minutes.from_now)
      expect(order.request).to eq true
      expect(order.aasm.to_state).to eq :requested
      expect { order.save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'succeeds if valid' do
      order.assign_attributes(arrives_at: 11.minutes.from_now)
      expect(order.request && order.save).to eq true
    end
  end

  describe 'nested address' do
    let(:new_address_attrs) { { content: 'CONTENT_NEW', code: '430105' } }
    let(:invalid_address_attrs) { { content: '', code: '430105' } }

    it 'saves with address' do
      order.address_attributes = new_address_attrs
      order.request && order.save!
      expect(order.address.content).to eq new_address_attrs[:content]
    end

    it 'raises error when invalid' do
      order.address_attributes = invalid_address_attrs
      expect{ order.save! }.to raise_error ActiveRecord:: RecordInvalid
    end

    it 'destroys existing associated address before assigning new one' do
      addresses_scope = -> { Address.where(addressable_type: 'Order') }
      order.request && order.save!
      expect(addresses_scope.call.count).to eq 1
      previous_address_id = order.address.id
      order.address_attributes = new_address_attrs
      order.save!
      current_address_id = addresses_scope.call.first.id
      expect(addresses_scope.call.count).to eq 1
      expect(current_address_id).not_to eq previous_address_id
      expect(order.address.id).to eq current_address_id
    end
  end

  describe 'state machine' do
    describe 'Request event' do
      it 'creates and requests order by user' do
        expect(order_requested).to be_persisted
        expect(order_requested.requested?).to eq true
        expect(order_requested.address).to be_valid
      end
    end

    describe 'Contract event' do
      it 'contracts a handyman' do
        order_requested.handyman = handyman
        order_requested.content = 'new content'
        expect(order_requested.contract && order_requested.save).to eq true

        order_requested.reload
        expect(order_requested.contracted?).to eq true
        expect(order_requested.content).to eq 'new content'
        expect(order_requested.handyman).to eq handyman
      end

      it 'fails to contract for invalid params' do
        expect(order_requested.contract).to eq true
        expect { order_requested.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    describe 'Cancel event' do
      let(:cancel_attributes) do
        {
          canceler: user,
          cancel_reason: 'some reasons'
        }
      end

      it 'raises exception if canceler is blank' do
        expect { order_requested.cancel }.to raise_error RuntimeError
      end

      it 'cancels requested order' do
        order_requested.assign_attributes(cancel_attributes)
        order_requested.cancel && order_requested.save!
        expect(order_requested.reload.canceled?).to eq true
      end

      it 'cancels contracted order' do
        order_contracted.assign_attributes(cancel_attributes)
        order_contracted.cancel && order_contracted.save!
        expect(order_contracted.reload.canceled?).to eq true
      end

      it 'generates canceled_at and canceler attributes' do
        order_contracted.assign_attributes(cancel_attributes)
        order_contracted.cancel && order_contracted.save!
        expect(order_contracted.canceled_at).to be_present
        expect(order_contracted.cancel_type).to eq 'User'
      end
    end

    describe 'Pay event' do
      let(:order) { create :contracted_order }

      describe 'user_total validations' do
        context 'With wechat payment' do
          shared_examples_for 'invalid payment' do
            let(:payment) { order.build_payment(payment_method: 'pingpp_wx_pub') }
            before { order.sync_from_user_total }

            it 'is invalid after #checkout and #save' do
              expect(order.valid?).to eq true
              expect(payment.checkout).to eq true
              expect(payment.save).to eq false
              expect(order.errors.messages.has_key? :user_total)
            end

            it 'will not create balance record' do
              expect { payment.checkout; payment.save }
                .not_to change(BalanceRecord, :count)
            end
          end

          it 'is valid for order within price range' do
            order.user_total = order.pricing[:total_price]
            expect(order.sync_from_user_total).to eq true
            payment = order.build_payment(payment_method: 'pingpp_wx_pub')
            payment.checkout
            payment.save!
            expect(order.payment?).to eq true
          end

          context 'When user_total exceding max limit' do
            before { order.user_total = 1e4 }
            it_behaves_like 'invalid payment'
          end

          context 'When user_total below min limit' do
            before { order.user_total = 5 }
            it_behaves_like 'invalid payment'
          end
        end

        context 'With cash payment' do
          shared_examples_for 'invalid payment' do
            let(:payment) { order.build_payment(payment_method: 'cash') }
            before { order.sync_from_user_total }

            it 'is invalid after #complete and #save' do
              expect(order.valid?).to eq true
              expect(payment.complete).to eq true
              expect(payment.save).to eq false
              expect(order.errors.messages.has_key? :user_total)
            end

            it 'will not create balance record' do
              expect { payment.complete; payment.save }
                .not_to change(BalanceRecord, :count)
            end
          end

          it 'is valid for order within price range' do
            order.user_total = order.pricing[:total_price]
            expect(order.sync_from_user_total).to eq true
            payment = order.build_payment(payment_method: 'cash')
            payment.complete
            payment.save!
            expect(order.completed?).to eq true
          end

          context 'When user_total exceding max limit' do
            before { order.user_total = 1e4 }
            it_behaves_like 'invalid payment'
          end

          context 'When user_total below min limit' do
            before { order.user_total = 5 }
            it_behaves_like 'invalid payment'
          end
        end
      end

    end
  end
end
