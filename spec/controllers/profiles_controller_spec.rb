require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  before { sign_in :user, user }
  let(:user) { create :user }
  let(:address_attrs) { { primary_address_attributes: attributes_for(:address) } }

  describe 'GET #profile/edit' do
    it 'returns http success' do
      get :edit
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    let(:new_attrs) do
      {
        email: 'new_email@example.com',
        phone: '13100008888',
        name: 'FOO',
        nickname: 'BAR',
        primary_address_attributes: {
          code: '430105',
          content: 'NEW_ADDRESS_CONTENT'
        }
      }
    end

    context 'with valid params' do
      it 'updates the profile attributes' do
        put :update, { profile: new_attrs }
        user.reload
        %w{ email phone name nickname }.each do |key|
          expect(user.send key).to eq new_attrs[key.to_sym]
        end
      end

      it 'updates the profile primary address' do
        expect(user.primary_address).to be nil
        put :update, { profile: new_attrs }
        primary_address = user.reload.primary_address
        expect(primary_address.content).to eq 'NEW_ADDRESS_CONTENT'
        expect(user.addresses).to eq [ primary_address ]
      end

      it 'replaces existing primary address' do
        user.update!(address_attrs)
        old_address = user.primary_address
        expect(old_address).to be_present

        put :update, { profile: new_attrs }
        new_address = user.reload.primary_address
        expect(new_address.content).to eq 'NEW_ADDRESS_CONTENT'
        expect(user.addresses).to match_array [ old_address, new_address ]
      end
    end

    context 'with invalid params' do
      let :invalids do
        [
          { phone: '1' },
          { email: '' },
          { primary_address_attributes: { content: '' } },
          { primary_address_attributes: { code: '' } },
        ]
      end

      it 're-renders the :edit template' do
        invalids.each do |invalid|
          put :update, { profile: new_attrs.merge(invalid) }
          expect(response).to render_template :edit
        end
      end
    end

  end
end
