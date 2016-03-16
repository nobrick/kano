require_relative 'sms/config'

module SMS
  include SMS::Messaging

  def self.config
    @config ||= Config.new
  end
end
