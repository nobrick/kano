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

  describe '#sync_from_user_total' do
    let(:order) { create :contracted_order }

    shared_examples_for 'sync from user total' do
      it 'keeping balance attributes correct' do
        order.sync_from_user_total(options)
        handyman_total = order.user_total + order.handyman_bonus_total
        expect(order.handyman_total).to eq handyman_total
        payment_total = order.user_total - order.user_promo_total
        expect(order.payment_total).to eq payment_total
      end

      it 'returns true on valid conditions' do
        expect(order.sync_from_user_total(options)).to eq true
      end
    end

    context 'When user_total option is given' do
      let(:options) { { user_total: 666 } }

      it 'sets user_total' do
        order.user_total = 777
        expect(order.sync_from_user_total options).to eq true
        expect(order.user_total).to eq 666
      end

      it_behaves_like 'sync from user total'
    end

    context 'When reset_bonus option is set to true' do
      let(:options) { { reset_bonus: true } }

      before do
        order.user_total = 300
        order.handyman_bonus_total = 10
        order.user_promo_total = 5
      end

      it 'resets handyman_bonus_total and user_promo_total to 0' do
        expect(order.sync_from_user_total options).to eq true
        expect(order.handyman_bonus_total).to eq 0
        expect(order.user_promo_total).to eq 0
      end

      it_behaves_like 'sync from user total'
    end
  end

  describe 'State machine' do
    describe 'Request event' do
      it 'creates and requests order by user' do
        expect(order_requested).to be_persisted
        expect(order_requested.requested?).to eq true
        expect(order_requested.address).to be_valid
      end

      describe 'Primary address' do
        let(:address_hash) do
          {
            address_attributes: {
              code: '430105',
              content: 'content 121'
            }
          }
        end

        context 'When user does not have the requested order adderss' do
          it 'adds and updates user primary address' do
            expect(order.request).to eq true
            content = address_hash[:address_attributes][:content]
            expect { order.save! }
              .to change { user.primary_address.reload.content }.to(content)
              .and change(user.addresses, :count).by 1
          end
        end

        context 'When user already has the requested order address' do
          let!(:address_1) do
            hash = address_hash[:address_attributes].merge(addressable: user)
            create :address, hash
          end

          let!(:address_2) do
            hash = address_hash[:address_attributes]
              .merge(addressable: user, content: 'content 139')
            create :address, hash
          end

          it 'sets user primary address to the order address' do
            expect(user.addresses).to include address_1
            expect(user.primary_address).not_to eq address_1
            expect(order.request).to eq true
            expect { order.save! }
              .to change { user.reload.primary_address }.to(address_1)
              .and change(user.addresses, :count).by(0)
          end
        end
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
            before { order.sync_from_user_total(reset_bonus: true) }

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
            expect(order.sync_from_user_total(reset_bonus: true)).to eq true
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
