require 'rails_helper'

RSpec.describe Users::Orders::ResendsController, type: :controller do
  before { sign_in :user, user }
  let(:user) { create :user }

  describe '#update' do
    let(:requested_order) { create :requested_order, user: user }
    let(:contracted_order) { create :contracted_order, user: user }
    shared_examples_for 'Resending order' do
      let(:id) { order.id }
      let(:expected_params) { {
        resend: {
          content: order.content,
          taxon_code: order.taxon_code
        }
      } }

      it 'redirects to order new page with :resend_id param' do
        post :update, id: id
        expect(response).to redirect_to new_user_order_path(expected_params)
      end

      it 'cancels order' do
        post :update, id: id
        expect(order.reload.canceled?).to eq true
      end
    end

    context 'Requested order' do
      let(:order) { requested_order }
      it_behaves_like 'Resending order'
    end

    context 'Contracted order' do
      let(:order) { contracted_order }
      it_behaves_like 'Resending order'
    end
  end
end
