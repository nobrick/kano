require 'rails_helper'
require 'support/wechat'
require 'support/devise_shared_examples'

RSpec.describe OmniauthCallbacksController, type: :controller do
  let(:nickname) { 'Jon Snow' }
  before { set_wechat_environment(nickname: nickname) }

  context 'never OmniAuthed before' do
    describe 'GET :wechat' do
      it_behaves_like 'user signs in' do
        before { get :wechat }
      end

      it 'creates a user' do
        expect { get :wechat }.to change { User.count }.by 1
      end
    end
  end  

  context 'OmniAuthed previously' do
    before do
      get :wechat
      controller.sign_out
    end

    let!(:previous_user) { User.first }

    describe 'initial status' do
      it 'creates a user' do
        expect(User.count).to eq 1
        expect(previous_user).to be_persisted
      end

      it_behaves_like 'no account signs in'
    end

    describe 'OmniAuth again' do
      before { get :wechat }

      it 'signs in by uid instead of creating new one' do
        expect(User.count).to eq 1
        expect(User.first).to eq previous_user
      end

      it_behaves_like 'user signs in'
    end
  end
end
