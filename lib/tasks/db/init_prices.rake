namespace :db do
  desc 'Initialize taxon pricing'
  task :init_prices do |t, args|
    config_file = File.join('config','pricing.yml')
    data = YAML.load(File.read(config_file))['pricing']
    data.values.each do |strategy|
      strategy['cities'].each do |city_code|
        find_and_update = lambda do |code, new_price|
          query = { city: city_code, code: code }
          item = TaxonItem.find_by(query)
          if item
            item.update!(price: new_price)
          else
            TaxonItem.create!(query.merge(price: new_price))
          end
        end

        find_and_update.('_traffic', strategy['base']['_traffic'])
        Taxon.taxon_codes.each do |code|
          find_and_update.(code, strategy['items'][code])
        end
      end
    end

    puts TaxonItem.count
    TaxonItem.order(:city, :created_at).each do |item|
      city = ChinaCity.get(item.city)
      item_name = Taxon.taxon_name(item.code)
      category = Taxon.category_name(item.code)
      puts "#{city}\t#{category}\t#{item_name}\t#{item.price}"
    end
  end
end
