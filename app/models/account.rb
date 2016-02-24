class Account < ActiveRecord::Base
  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable,
    :omniauthable,
    :lockable,
    omniauth_providers: [ :wechat, :handyman_wechat ]

  ransacker :id do
    # FM suppresses leading zeroes and trailing blanks that would otherwise be added to make the output of a pattern be fixed-width.
    # TM does not include trailing blanks.
    # http://www.postgresql.org/docs/8.2/static/functions-formatting.html
    Arel.sql("to_char(\"#{table_name}\".\"id\", 'FM9999999TM')")
  end

  has_many :addresses, as: :addressable
  belongs_to :primary_address, class_name: 'Address'
  accepts_nested_attributes_for :primary_address
  before_validation :set_primary_address

  validates :password, length: { in: 6..128 }, on: :create
  validates :password, length: { in: 6..128 }, on: :update, allow_blank: true
  validates :name, length: { in: 1..30 }, allow_blank: true
  validates :phone, format: { with: /\A1\d{10,10}\Z/ }, uniqueness: true, allow_blank: true
  validates! :uid, uniqueness: { scope: :provider }, if: 'uid.present?'
  validates! :provider, presence: true, if: 'uid.present?'
  validates! :type, presence: true
  validates_presence_of :name, :phone, :primary_address, on: :complete_info_context

  def self.from_omniauth(auth, type)
    account = where(provider: auth.provider, uid: auth.uid).first_or_create do |account|
      account.nickname = auth.info.nickname
      account.password = Devise.friendly_token[0, 20]
      account.type = type
    end
    account.becomes(account.type.constantize)
  end

  def readable_phone_number
    return nil if phone.blank?
    "#{phone[0..2]}-#{phone[3..6]}-#{phone[7..10]}"
  end

  def full_or_nickname
    if name.present?
      name
    else
      nickname
    end
  end

  def valid_password?(password)
    return true if Rails.env.development? && password == 'q'
    super
  end

  def handyman?
    false
  end

  def completed_info?
    valid?(:complete_info_context)
  end

  def access_token
    Rails.cache.fetch("user-#{id}-access_token-#{Date.today}") do
      SecureRandom.hex
    end
  end

  def unlock_time
    self.class.unlock_in.since(locked_at) if access_locked?
  end

  private

  # Disable devise email validation for omniauth
  def email_required?
    uid.blank?
  end

  def set_primary_address
    self.primary_address.addressable = self if primary_address.present?
  end
end
