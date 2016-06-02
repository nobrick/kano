require 'rails_helper'

RSpec.describe Handymen::Contracts::ResendsController, type: :controller do
  before { sign_in :handyman, handyman }
  let(:handyman) { create :handyman }

  describe '#update' do
    let!(:order) do
      create :contracted_order,
        handyman: handyman,
        arrives_at: 1.hour.ago,
        ignores_arrives_at_validation: true
    end

    let(:id) { order.id }
    let(:new_order) { Order.order(created_at: :desc).first }

    it 'cancels order' do
      put :update, id: id
      expect(order.reload.canceled?).to eq true
    end

    it 'creates a new order' do
      expect { put :update, id: id }.to change(Order, :count).by 1
      expect(new_order.content).to eq order.content
      expect(new_order.user).to eq order.user
      expect(new_order.handyman).to be_nil
      expect(new_order.taxon_code).to eq order.taxon_code
      expect(new_order.address.content).to eq order.address.content
      expect(new_order.address.code).to eq order.address.code
    end

    it 'redirects to the contract url' do
      put :update, id: id
      expect(response).to redirect_to handyman_contract_url(order)
    end

    context 'With no-access order' do
      let!(:order_with_no_access) { create :contracted_order }
      let(:id) { order_with_no_access.id }

      it 'does not allow updating orders that belong to others' do
        expect { put :update, id: id }.not_to change(Order, :count)
        expect(order_with_no_access.reload).not_to be_canceled
      end
    end
  end
end
