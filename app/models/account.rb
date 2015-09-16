class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :omniauthable, omniauth_providers: [ :wechat ]
  validates :password, length: { in: 6..128 }, on: :create
  validates :password, length: { in: 6..128 }, on: :update, allow_blank: true
  validates :uid, uniqueness: { scope: :provider }, if: 'uid.present?'

  validates :name, presence: true, length: { in: 1..30 }, on: :complete_info
  validates :phone, format: { with: /1\d{10,10}/ }, uniqueness: true, on: :complete_info

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |account|
      account.nickname = auth.info.nickname
      account.password = Devise.friendly_token[0, 20]
    end
  end

  def self.new_with_session(params, session)
    auth = session['devise.facebook_data']
    super.tap do |account|
      if auth && auth['extra']['raw_info']
        account.nickname = auth['info']['nickname'] if account.nickname.blank?
        account.password = Devise.friendly_token[0, 20]
      else
        # Wechat session auth loading failure.
      end
    end
  end

  def valid_password?(password)
    return true if Rails.env.development? && password == 'q'
    super
  end

  def handyman?
    false
  end

  def completed?
    valid?(:complete_info_context)
  end
end
