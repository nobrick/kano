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
        expect(order.aasm.current_state).to eq :contracted
        expect(order.content).to eq 'NEW'
        expect(order.handyman).to be_a Handyman
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
          transfer_type: :handyman,
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
        ret = order.transfer!
        expect(ret).to eq true

        order.reload
        expect(order.transferred?).to eq true
        expect(order.transfer_reason).to eq 'some reason'
        expect(order.transfer_type).to eq 'handyman'
        expect(order.transferor).to eq handyman
        expect(order.transferred_at).to be_present
        expect(order.transferee_order).to be_present
      end

      it 'creates an new order when transfer suceeds' do
        expect { order.transfer! }.to change { Order.count }.by 1
      end

      it 'fails for invalid params' do
        invalid_sets.each do |set|
          order.assign_attributes(valid_attrs)
          expect(order.may_transfer?).to eq true

          set.call
          expect(order.may_transfer?).to eq false
          expect{ order.transfer! }.to raise_error AASM::InvalidTransition
        end
      end

      it 'rolls back for creating new order when transfer fails' do
        expect { order.transfer!(invalid) rescue nil }
          .not_to change { Order.count }
      end
    end

  end
end
