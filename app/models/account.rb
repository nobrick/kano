class Account < ActiveRecord::Base
  include WithRedisObjects
  include IdRandomizable
  include Serializable

  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable,
    :omniauthable,
    :lockable,
    omniauth_providers: [ :wechat, :handyman_wechat ]

  has_many :addresses, as: :addressable
  belongs_to :primary_address, class_name: 'Address'
  accepts_nested_attributes_for :primary_address
  validates :password, length: { in: 6..128 }, on: :create
  validates :password, length: { in: 6..128 }, on: :update, allow_blank: true
  validates :name, length: { in: 1..30 }, allow_blank: true
  validates :phone, format: { with: /\A1\d{10}\Z/ }, uniqueness: true, allow_blank: true
  validates! :uid, uniqueness: { scope: :provider }, if: 'uid.present?'
  validates! :provider, presence: true, if: 'uid.present?'
  validates! :type, presence: true
  validates_presence_of :name, :phone, :primary_address, on: :complete_info_context
  before_validation :set_primary_address
  before_validation :set_phone
  before_validation :set_name
  before_save :update_phone_verified_at

  value :phone_vcode, expiration: 5.minutes
  counter :phone_vcode_sent_times_in_hour, expiration: 1.hour

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
    elsif nickname.present?
      nickname
    else
      "ID_#{id}"
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

  def phone_verified?
    phone_verified_at && !phone_changed?
  end

  def was_phone_verified?
    phone_verified_at.present?
  end

  private

  def set_phone
    self.phone = nil if phone.blank?
  end

  def set_name
    self.name.try :strip!
    self.name = nil if self.name.blank?
  end

  # Disable devise email validation for omniauth
  def email_required?
    uid.blank?
  end

  def set_primary_address
    self.primary_address.addressable = self if primary_address.present?
  end

  def update_phone_verified_at
    return if phone.nil? || phone_verified?
    self.phone_verified_at = Time.now
  end
end
