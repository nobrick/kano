require 'rails_helper'

RSpec.describe SMS do
  describe '#push_verification' do
    before do
      body_pattern = {
        'apikey' => /.+/,
        'mobile'=> /\A\d{11}\z/,
        'tpl_id'=> /\A\d+\z/,
        'tpl_value' => /\A%23code%23=\d{4}\z/
      }
      stub_request(:post, uri)
        .with(body: body_pattern)
        .to_return(body: success_hash.to_json)
    end

    let(:uri) { 'http://sms.yunpian.com/v1/sms/tpl_send.json' }
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

    it 'sends SMS verification message' do
      expect(SMS.push_verification('13100001111', '1234')).to eq success_hash
    end
  end
end
