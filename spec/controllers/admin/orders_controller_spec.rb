require 'rails_helper'

RSpec.describe Admin::OrdersController, type: :controller do
  before do
    sign_in :user, admin
  end
  let(:admin) { create :admin }

  describe "#cancel" do
    let(:requested_order) { create :requested_order }
    let(:contracted_order) { create :contracted_order }

    it 'cancels requested order' do
      put :cancel, id: requested_order.id, order: { cancel_reason: "cancel reason" }
      expect(requested_order.reload.canceled?).to eq true
    end

    it 'cancels contracted order' do
      put :cancel, id: contracted_order.id, order: { cancel_reason: "cancel reason" }
      expect(contracted_order.reload.canceled?).to eq true
    end
  end
end
