require 'rails_helper'
require 'support/devise_shared_examples'

RSpec.describe SessionsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:account] }

  let!(:user) { create :user, attrs }
  let(:attrs) { { email: 'jonsnow@gmail.com',
                  password: 'winter',
                  remember_me: '0' } }

  context 'valid sign in' do
    describe 'sign_in helper method' do
      before { sign_in :user, user }
      it_behaves_like 'user signs in'
    end

    describe 'POST :create' do
      before { post :create, account: attrs }
      it_behaves_like 'user signs in'
    end
  end

  context 'invalid sign in' do
    before { post :create, account: attrs.merge(password: 'INVALID') }
    it_behaves_like 'no account signs in'
  end

  describe 'sign out' do
    before do
      sign_in :user, user
      expect(session.keys).to include 'warden.user.user.key'
      delete :destroy
    end

    it_behaves_like 'no account signs in'
  end
end
