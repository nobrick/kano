require 'rails_helper'
require 'support/devise_shared_examples'

RSpec.describe Users::RegistrationsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  let(:attrs) do
    {
      email: 'jon@gmail.com',
      phone: '13100001111',
      name: 'Jon Snow',
      password: 'winter',
      password_confirmation: 'winter'
    }
  end

  describe 'valid sign up' do
    it 'creates a user' do
      expect { post :create, user: attrs }.to change { User.count }.by 1
    end

    describe 'POST :create' do
      before { post :create, user: attrs }
      it_behaves_like 'user signs in'
    end
  end
end
