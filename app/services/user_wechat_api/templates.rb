module UserWechatApi
  module Templates
    def self.included(base)
      base.extend AfterContract
      base.extend AfterPayment
    end
  end
end
