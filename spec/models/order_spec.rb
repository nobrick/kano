require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:user) { create :user }
  let(:handyman) { create :handyman }
  let(:address_hash) { { address_attributes: attributes_for(:address) } }
  let(:order_attrs) { attributes_for(:order).merge(address_hash) }
  let(:order) { Order.new(order_attrs).tap { |o| o.user = user } }
  let(:order_requested) { create :requested_order }
  let(:order_contracted) { create :contracted_order }
  let(:order_transferred) do
    order_contracted.tap { |o| o.attributes = transfer_attrs; o.transfer && o.save! }
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
  end
end
