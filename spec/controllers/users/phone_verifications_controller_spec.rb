require 'rails_helper'

RSpec.describe Users::PhoneVerificationsController, type: :controller do
  let(:user) { create :user }
  let(:pushed) { [] }
  before do
    sign_in :user, user
    allow(SMS).to receive(:push_verification) { |p, c| pushed << [ p, c ] }
      .and_return(success_hash)
  end

  let(:success_hash) do
    {
      'code' => 0,
      'msg' => 'OK',
      'result' => {
        'count' => 1,
        'fee' => 0.055,
        'sid' => 5224803768
      }
    }
  end

  describe '#create' do
    before { xhr :post, :create, phone: phone }
    let(:phone) { '13100001111' }
    let(:xhr_create) { -> { xhr :post, :create, phone: phone } }
    let(:xhr_create_and_parse) do
      -> { xhr_create.call; JSON.parse(response.body) }
    end

    it 'pushes verification message' do
      expected = { code: 0, msg: 'OK' }
      expect(response.body).to eq(expected.to_json)
    end

    it 'increases user phone_vcode_sent_times_in_hour count until 3' do
      fetch_value = -> { user.phone_vcode_sent_times_in_hour.value }
      expect(xhr_create).to change(&fetch_value).from(1).to(2)
      expect(xhr_create).to change(&fetch_value).from(2).to(3)
      expect(xhr_create).not_to change(&fetch_value).from(3)
    end

    it 'sends the same verification code within 5 minutes' do
      xhr_create.call
      expect(pushed[0]).to eq(pushed[1])
      user.phone_vcode.expire(0)
      xhr_create.call
      expect(pushed[0].last).not_to eq(pushed[2].last)
    end

    it 'has to wait for an hour to when exceeding request limit' do
      2.times { expect(xhr_create_and_parse.call['code']).to eq 0 }

      error = { 'code' => -1, 'msg' => 'TOO_MANY_REQUESTS' }
      expect(xhr_create_and_parse.call).to include error

      user.phone_vcode_sent_times_in_hour.expire(0)
      expect(xhr_create_and_parse.call['code']).to eq 0
    end
  end
end
