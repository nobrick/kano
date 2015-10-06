require 'rails_helper'

RSpec.describe Users::OrdersController, type: :controller do
  before { sign_in :user, user }
  let(:user) { create :user }
  let(:address_params) { { address_attributes: attributes_for(:address) } }
  let(:valid_params) { { order: attributes_for(:order).merge(address_params) } }
  let(:invalid) { { address_attributes: { content: '' } } }
  let(:invalid_params) { valid_params.merge(order: invalid) }

  describe 'GET #create' do
    context 'with valid params' do
      it 'creates new order' do
        expect { post :create, valid_params }.to change(Order, :count).by 1
      end

      it 'creates newly associated address' do
        expect { post :create, valid_params }.to change(Address, :count).by 1
      end

      it 'assigns newly created order' do
        post :create, valid_params
        order = assigns(:order)
        expect(order).to be_a Order
        expect(order).to be_persisted
        expect(order.requested?).to eq true
      end

      it 'persists associated address' do
        post :create, valid_params
        address = assigns(:order).address
        expect(address).to be_a Address
        expect(address).to be_persisted
        expect(address.addressable).to eq assigns(:order)
      end
    end

    context 'with invalid params' do
      it 'does not create new order' do
        expect { post :create, invalid_params }.not_to change(Order, :count)
      end

      it 'does not create and persist new address' do
        expect { post :create, invalid_params }.not_to change(Address, :count)
      end

      it 'assigns unsaved @order' do
        post :create, invalid_params
        expect(assigns(:order)).to be_a_new Order
      end

      it 'assigns associated unsaved address' do
        post :create, invalid_params
        address = assigns(:order).address
        expect(address).to be_a_new Address
      end
    end
  end
end
