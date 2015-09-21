class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true
  before_validation :set_from_code, if: 'code.present?'
  before_destroy :nullify_primary_address, if: 'primary?'

  validates :addressable, presence: true
  validates :content, presence: true
  validates :code, format: /\A\d{6,6}\z/
  validates! :province, presence: true
  validates! :city, presence: true
  validates! :district, presence: true

  def primary?
    addressable.try(:primary_address_id) == id
  end

  def code=(arg)
    super.tap { set_from_code }
  end

  def district_with_prefix
    "#{province}#{city}#{district}"
  end

  private

  def set_from_code
    self.district = ChinaCity.get(code)
    self.city = ChinaCity.get(code[0..3] + '00')
    self.province = ChinaCity.get(code[0..1] + '0000')
  end

  def nullify_primary_address
    addressable.update_attribute :primary_address, nil
  end
end
