if Rails.env.development?
  include WebMock::API
  uri = 'http://sms.yunpian.com/v1/sms/tpl_send.json'
  success_hash = {
    'code' => 0,
    'msg' => 'OK',
    'result' => {
      'count' => 1,
      'fee' => 0.055,
      'sid' => 5224803768
    }
  }
  stub_request(:post, uri).to_return(body: success_hash.to_json)
end
