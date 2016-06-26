module TaxonItem::TestHelpers
  def set_taxon_items(options = {})
    city_code = options.fetch(:city_code, 430100)
    taxon_code = options.fetch(:taxon_code, 'electronic/lighting')
    reload = options.fetch(:reload, true)
    TaxonItem.create(city: city_code, code: taxon_code, price: 50)
    TaxonItem.create(city: city_code, code: '_traffic', price: 10)
    TaxonItem.reset_prices if reload
  end
end

RSpec.configure do |config|
  config.include TaxonItem::TestHelpers
end
