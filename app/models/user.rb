class User < Account
  has_many :orders

  def on_wechat?
    provider == 'wechat'
  end
end
