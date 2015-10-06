class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true
  before_validation :set_from_code, if: 'code.present?'
  before_destroy :nullify_primary_address, if: 'primary?'

  validates :addressable, presence: true
  validates :content, presence: true
  validate { errors.add(:base, '请选择您所在的地区') unless code_valid? }

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

  def district_with_prefix
    "#{province}#{city}#{district}"
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
