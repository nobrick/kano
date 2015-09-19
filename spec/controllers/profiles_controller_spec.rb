require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  before { sign_in user }
  let(:user) { create :user }

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
        nickname: 'BAR'
      }
    end

    it 'updates the profile with valid params' do
      put :update, { profile: new_attrs }
      user.reload
      new_attrs.each { |k, v| expect(user.send k).to eq v }
    end

    it 're-renders the :edit template with invalid params' do
      invalids = [ { phone: '1' }, { email: '' } ]
      invalids.each do |invalid|
        put :update, { profile: new_attrs.merge(invalid) }
        expect(response).to render_template :edit
      end
    end
  end
end
