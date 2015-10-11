require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:user) { create :user }
  let(:handyman) { create :handyman }
  let(:address_hash) { { address_attributes: attributes_for(:address) } }
  let(:order_attrs) { attributes_for(:order).merge(address_hash) }
  let(:order) { Order.new(order_attrs).tap { |o| o.user = user } }
  let(:order_requested) { create :order, state: 'requested' }
  let(:order_contracted) { create :order, state: 'contracted' }

  let(:order_transferred) do
    order_contracted.tap { |o| o.attributes = transfer_attrs; o.transfer! }
  end

  let(:transfer_attrs) do 
    {
      transfer_reason: 'some reason',
      transfer_type: 'handyman',
      transferor: handyman
    }
  end

  it 'creates an order' do
    expect(order_requested).to be_persisted
    expect(order_requested.user).to be_persisted
  end

  it 'arrives_at field must be valid' do
    order.assign_attributes(arrives_at: 1.minutes.from_now)
    expect(order.request!).to eq false
    order.assign_attributes(arrives_at: 11.minutes.from_now)
    expect(order.request!).to eq true
  end

  describe 'nested address' do
    let(:new_address_attrs) { { content: 'CONTENT_NEW', code: '430105' } }
    let(:invalid_address_attrs) { { content: '', code: '430105' } }

    it 'saves with address' do
      order.address_attributes = new_address_attrs
      order.request!
      expect(order.address.content).to eq new_address_attrs[:content]
    end

    it 'raises error when invalid' do
      order.address_attributes = invalid_address_attrs
      expect{ order.save! }.to raise_error ActiveRecord:: RecordInvalid
    end

    it 'destroys existing associated address before assigning new one' do
      addresses_scope = -> { Address.where(addressable_type: 'Order') }
      order.request!
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
    it 'will raise error by calling event name wihout exclamation' do
      order_requested.handyman = handyman
      expect { order_requested.contract }.to raise_error RuntimeError
    end

    describe 'request event' do
      it 'creates and requests order by user' do
        expect(order_requested).to be_persisted
        expect(order_requested.requested?).to eq true
        expect(order_requested.address).to be_valid
      end
    end

    describe 'contract event' do
      it 'contracts a handyman' do
        order_requested.handyman = handyman
        order_requested.content = 'new content'
        expect(order_requested.contract!).to eq true

        order_requested.reload
        expect(order_requested.contracted?).to eq true
        expect(order_requested.content).to eq 'new content'
        expect(order_requested.handyman).to eq handyman
      end

      it 'fails to contract for invalid params' do
        expect(order_requested.contract!).to be false
      end
    end

    describe 'transfer event' do
      let(:invalid_sets) do
        [
          -> { order_contracted.transfer_reason = '' },
          -> { order_contracted.transfer_type = 'INVALID' },
          -> { order_contracted.transferor = nil }
        ]
      end

      context 'when succeeds' do
        it 'transfers to an order' do
          order_contracted.assign_attributes(transfer_attrs)
          expect(order_contracted.transfer!).to eq true
        end

        it 'persists attributes correctly' do
          order_transferred.reload
          expect(order_transferred.transferred?).to eq true
          transfer_attrs.each do |key, value|
            expect(order_transferred.send key).to eq value
          end
          expect(order_transferred.transferred_at).to be_present
        end

        it 'creates an new order when transfer suceeds' do
          order_contracted.assign_attributes(transfer_attrs)
          expect { order_contracted.transfer! }.to change { Order.count }.by 1
          expect(order_contracted.transferee_order).to be_valid
        end

        it 'transfers with all necessary attrs copied to new order' do
          order_contracted.assign_attributes(transfer_attrs)
          order_contracted.transfer!
          attrs_transferred = [ :user, :taxon_code, :content, :arrives_at ]
          attrs_transferred.each do |sym|
            expect(order_contracted.transferee_order.send sym)
              .to eq order_contracted.send sym
          end
          expect(order_contracted.transferee_order.requested?).to eq true
        end

        it 'creates new address' do
          order_contracted.assign_attributes(transfer_attrs)
          expect { order_contracted.transfer! }.to change { Address.count }.by 1
          %w{ district_with_prefix content code }.each do |method|
            expect(order_contracted.transferee_order.address.send method)
              .to eq order_contracted.address.send(method)
          end
        end
      end

      context 'when fails' do
        it 'will not create new order for invalid params' do
          invalid_sets.each do |set|
            order_contracted.reload.assign_attributes(transfer_attrs)
            set.call
            expect { order_contracted.transfer! }.not_to change { Order.count }
            expect(order_contracted.transferee_order).to be_nil
          end
        end

        it 'resets transferee_order and transferred_at' do
          expect(order_contracted.transfer!).to eq false
          expect(order_contracted.transferee_order).to be_nil
          expect(order_contracted.transferred_at).to be_nil
        end

        it 'fails to transfer for invalid params' do
          invalid_sets.each do |set|
            order_contracted.reload.assign_attributes(transfer_attrs)
            set.call
            expect(order_contracted.transfer!).to eq false
          end
        end
      end
    end
  end
end
