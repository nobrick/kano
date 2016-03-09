module SMS
  module Request
    def post(api, options = {})
      options[:apikey] = SMS.config.api_key
      uri = URI.join(base_url, api)
      result = Net::HTTP.post_form(uri, options)
      parse result.body
    end

    private

    def parse(body)
      begin
        ActiveSupport::JSON.decode body
      rescue => e
        {
          code: 502,
          msg: 'Content parsing error',
          detail: e.to_s
        }
      end
    end

    def base_url
      'http://sms.yunpian.com/v1/'
    end

    module_function :post, :parse, :base_url
  end
end
