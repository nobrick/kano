class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :password, length: { in: 6..128 }, on: :create
  validates :password, length: { in: 6..128 }, on: :update, allow_blank: true
  validates :name, presence: true, length: { in: 1..30 }
  validates :uid, uniqueness: { scope: :provider }, if: 'uid.present?'
  validates :phone, format: { with: /1\d{10,10}/ }
end
