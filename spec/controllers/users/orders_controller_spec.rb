require 'rails_helper'

RSpec.describe Users::OrdersController, type: :controller do
  before { sign_in :user, user }
  let(:user) { create :user }
  let(:address_params) { { address_attributes: attributes_for(:address) } }
  let(:valid_params) do
    {
      order: attributes_for(:order).merge(address_params),
      arrives_at_shift: '1'
    }
  end
  let(:invalid) { { address_attributes: { content: '' } } }
  let(:invalid_params) { valid_params.merge(order: invalid) }

  describe 'GET #create' do
    context 'With valid params' do
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

      describe 'Arrives at shift' do
        it 'picks today for arrives_at' do
          post :create, valid_params.merge(arrives_at_shift: 0)
          order = assigns(:order)
          expect(order.arrives_at.to_date).to eq Date.today
        end

        it 'picks tomorrow for arrives_at' do
          post :create, valid_params.merge(arrives_at_shift: 1)
          order = assigns(:order)
          expect(order.arrives_at.to_date).to eq Date.tomorrow
        end

        it 'picks the day after tomorrow for arrives_at' do
          post :create, valid_params.merge(arrives_at_shift: 2)
          order = assigns(:order)
          expect(order.arrives_at.to_date).to eq 1.day.since(Date.tomorrow)
        end
      end
    end

    context 'With invalid params' do
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

    describe 'User phone update' do
      let!(:prev_phone) { user.phone }
      let!(:prev_verified) { user.phone_verified? }
      let(:vcode) { '1111' }
      let(:phone) { '13166661111' }

      shared_examples_for 'Failure for saving order and user phone' do
        it 'fails to create an order' do
          expect { post :create, params }.not_to change(Order, :count)
        end

        it 'fails to update user phone attribute' do
          post :create, params
          user.reload
          expect(user.phone).to eq prev_phone
          expect(user.phone_verified?).to eq prev_verified
        end
      end

      shared_examples_for 'Order and user phone saving failure cases' do
        context 'With invalid verification code' do
          let(:params) { valid_params.merge(vcode: '0000', phone: phone) }
          it_behaves_like 'Failure for saving order and user phone'
        end

        context 'With blank verification code' do
          let(:params) { valid_params.merge(vcode: '', phone: phone) }
          it_behaves_like 'Failure for saving order and user phone'
        end

        context 'With blank phone number' do
          let(:params) { valid_params.merge(vcode: vcode, phone: '') }
          it_behaves_like 'Failure for saving order and user phone'
        end

        context 'With duplicate phone number' do
          before { create :user, phone: phone }
          let(:params) { valid_params.merge(vcode: vcode, phone: phone) }
          it_behaves_like 'Failure for saving order and user phone'
        end

        context 'With invalid phone number' do
          let(:params) { valid_params.merge(vcode: vcode, phone: '110') }
          it_behaves_like 'Failure for saving order and user phone'
        end
      end

      context 'When user has no verified phone number' do
        let(:user) { create :user, :unverified }

        context 'When verification code is sent and not expired' do
          before { user.phone_vcode.value = vcode }

          context 'With valid verification code' do
            let(:params) { valid_params.merge(vcode: vcode, phone: phone) }

            it 'creates an order' do
              expect { post :create, params }.to change(Order, :count).by 1
            end

            it 'updates user phone attribute' do
              post :create, params
              user.reload
              expect(user.phone).to eq phone
              expect(user).to be_phone_verified
            end
          end

          it_behaves_like 'Order and user phone saving failure cases'
        end

        context 'When verification code is expired or not sent' do
          before { user.phone_vcode = nil }
          it_behaves_like 'Order and user phone saving failure cases'
        end
      end

      context 'When user verified phone number before' do
        let(:user) { create :user }

        shared_examples_for 'Cases with existing verified phone number' do
          context 'With existing phone number and no verification code' do
            let(:params) { valid_params.merge(phone: prev_phone) }

            it 'creates an order' do
              expect { post :create, params }.to change(Order, :count).by 1
            end

            it 'does not change user phone' do
              post :create, params
              user.reload
              expect(user.phone).to eq prev_phone
              expect(user).to be_phone_verified
            end
          end
        end

        context 'When verification code is sent and not expired' do
          before { user.phone_vcode.value = vcode }

          context 'With valid verification code' do
            let(:params) { valid_params.merge(vcode: vcode, phone: phone) }

            it 'creates an order' do
              expect { post :create, params }.to change(Order, :count).by 1
            end

            it 'updates user phone attribute' do
              post :create, params
              user.reload
              expect(user.phone).to eq phone
              expect(user).to be_phone_verified
            end
          end

          it_behaves_like 'Cases with existing verified phone number'
          it_behaves_like 'Order and user phone saving failure cases'
        end

        context 'When verification code is expired or not sent' do
          before { user.phone_vcode = nil }
          it_behaves_like 'Cases with existing verified phone number'
          it_behaves_like 'Order and user phone saving failure cases'
        end
      end
    end
  end

  describe '#cancel' do
    let(:requested_order) { create :requested_order, user: user }
    let(:contracted_order) { create :contracted_order, user: user }
    let(:others_order) { create :requested_order, user: create(:user) }

    it 'cancels requested order' do
      put :cancel, id: requested_order.id
      expect(requested_order.reload.canceled?).to eq true
    end

    it 'cancels contracted order' do
      put :cancel, id: contracted_order.id
      expect(contracted_order.reload.canceled?).to eq true
    end

    it 'fails to cancel orders that does not belongs to the user' do
      put :cancel, id: others_order.id
      expect(others_order.reload.canceled?).to eq false
    end
  end
end
