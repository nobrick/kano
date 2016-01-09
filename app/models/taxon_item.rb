class TaxonItem < ActiveRecord::Base
  validates :code, presence: true, uniqueness: { scope: :city }
  validates :price, presence: true
  validates :city, format: { with: /\A\d{4}00\z/ }

  def self.prices(reset = false)
    @@prices ||= nil
    return @@prices if @@prices && !reset

    prices = {}
    TaxonItem.pluck(:city, :code, :price).each do |item|
      prices[item[0]] ||= {}
      prices[item[0]][item[1]] = item[2].to_i
    end
    @@prices = prices
  end

  def self.prices_json(reset = false)
    @@prices_json ||= prices(reset).to_json
  end

  def self.reset_prices
    prices(true)
  end
end
