class Address < ActiveRecord::Base
  include Serializable

  belongs_to :addressable, polymorphic: true
  before_validation :set_from_code, if: 'code.present?'
  before_destroy :nullify_primary_address, if: 'primary?'

  validates :addressable, presence: true
  validates :content, presence: true
  validate { errors.add(:base, '请选择您所在的地区') unless code_valid? }

  # Look up addresses in the database with the same attributes except +:id+ of
  # the given address.
  #
  # @param address [Address] The address.
  def self.lookup(address)
    where(address.attribute_hash)
  end

  def primary?
    addressable.try(:primary_address_id) == id
  end

  def code=(the_code)
    if code_valid?(the_code)
      super.tap { set_from_code }
    else
      nil
    end
  end

  def full_content
    "#{district_with_prefix} #{content}"
  end

  def to_s
    full_content
  end

  def district_with_prefix
    district_revised = district == '市辖区' ? '' : district
    "#{province}#{city}#{district_revised}"
  end

  def city_code
    if code
      code[0..3] + '00'
    else
      nil
    end
  end

  def province_code
    if code
      code[0..1] + '0000'
    else
      nil
    end
  end

  def attribute_hash
    { code: code, content: content }
  end

  private

  def code_valid?(the_code = code)
    !!the_code.try(:match, /\A\d{6,6}\z/)
  end

  def set_from_code
    self.district = ChinaCity.get(code)
    self.city = ChinaCity.get(city_code)
    self.province = ChinaCity.get(province_code)
    raise 'code invalid' if province.blank? || city.blank? || district.blank?
  end

  def nullify_primary_address
    addressable.update_attribute :primary_address, nil
  end
end
