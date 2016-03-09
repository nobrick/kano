module SMS
  module Messaging
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def push_verification(phone, code)
        push 'verification', phone, code: code
      end

      private

      def push(template_name, phone, options = {})
        request_options = {
          mobile: phone,
          tpl_id: SMS.config.templates[template_name]['template_id'],
          tpl_value: content_params_for(options)
        }
        Request.post 'sms/tpl_send.json', request_options
      end

      def content_params_for(options = {})
        options.map { |k, v| [ "##{k}#", v ] }.to_h.to_query
      end
    end
  end
end
