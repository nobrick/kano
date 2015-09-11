require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:order) { create :order }
  let(:handyman) { create :handyman }

  it 'creates an order' do
    expect(order).to be_a Order
    expect(order.user).to be_a User
  end

  describe 'state machine' do
    it 'will raise error by calling event name wihout exclamation' do
      order.handyman = handyman
      expect { order.contract }.to raise_error RuntimeError
    end

    describe 'contract event' do
      it 'contracts a handyman' do
        order.handyman = handyman
        order.content = 'NEW'
        expect(order.contract!).to eq true

        order.reload
        expect(order.contracted?).to eq true
        expect(order.content).to eq 'NEW'
        expect(order.handyman).to eq handyman
      end

      it 'fails to contract for invalid params' do
        expect(order.contract!).to be false
      end
    end

    describe 'transfer event' do
      before do
        order.handyman = handyman
        raise unless order.contract!
        order.assign_attributes(valid_attrs)
      end

      let(:valid_attrs) do 
        {
          transfer_reason: 'some reason',
          transfer_type: 'handyman',
          transferor: handyman
        }
      end

      let(:invalid_sets) do
        [
          -> { order.transfer_reason = '' },
          -> { order.transfer_type = 'INVALID' },
          -> { order.transferor = nil }
        ]
      end

      it 'transfers to an order' do
        expect(order.transfer!).to eq true
        order.reload
        expect(order.transferred?).to eq true
        valid_attrs.each do |key, value|
          expect(order.send key).to eq value
        end
        expect(order.transferred_at).to be_present
      end

      it 'creates an new order when transfer suceeds' do
        expect { order.transfer! }.to change { Order.count }.by 1
        expect(order.reload.transferee_order).to be_present
      end

      it 'transfers with all necessary attrs copied to new order' do
        order.transfer!
        attrs_transferred = [ :user, :taxon_code, :content, :arrives_at ]
        attrs_transferred.each do |sym|
          expect(order.transferee_order.send sym).to eq order.send sym
        end
        expect(order.transferee_order.requested?).to eq true
      end

      it 'will not create new order when transfer fails' do
        invalid_sets.each do |set|
          order.reload.assign_attributes(valid_attrs)
          set.call
          expect { order.transfer! }.not_to change { Order.count }
        end
      end

      it 'fails to transfer for invalid params' do
        invalid_sets.each do |set|
          order.reload.assign_attributes(valid_attrs)
          set.call
          expect(order.transfer!).to eq false
        end
      end
    end

  end
end
