class User < Account
  include OrdersAssociation

  def on_wechat?
    provider == 'wechat'
  end
end
