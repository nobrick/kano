require 'rails_helper'

RSpec.describe Handymen::OrdersController, type: :controller do
  before { sign_in :handyman, handyman }
  let(:user) { create :user }
  let(:handyman) { create :handyman_with_taxons }
  let(:order) { create :requested_order }

  context 'When uncompleted handyman signs in' do
    let(:handyman) { create :handyman }

    describe 'GET #index' do
      it 'redirects to the completion page' do
        get :index
        expect(response).to redirect_to complete_handyman_profile_url
      end
    end
  end

  context 'When completed handyman signs in' do
    describe 'GET #index' do
      it 'returns success and renders :index' do
        get :index
        expect(response).to have_http_status(:success)
        expect(response).to render_template :index
      end
    end

    describe 'GET #show' do
      it 'returns success and renders :show' do
        get :show, id: order.id
        expect(response).to have_http_status(:success)
        expect(response).to render_template :show
      end
    end

    describe 'POST #update' do
      before { post :update, id: order.id }
      it 'contracts the order' do
        expect(order.reload.handyman).to eq handyman
      end

      it 'sets handyman bonus to the order' do
        expect(order.reload.handyman_bonus_total).to eq 5
      end

      it 'redirects to handyman_contract_url' do
        expect(response)
          .to redirect_to handyman_contract_url(order)
      end
    end
  end
end
