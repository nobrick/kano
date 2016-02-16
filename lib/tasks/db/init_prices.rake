namespace :db do
  desc 'Initialize taxon pricing'
  task :init_prices do |t, args|
    config_file = File.join('config','pricing.yml')
    data = YAML.load(File.read(config_file))['pricing']
    data.values.each do |strategy|
      strategy['cities'].each do |city_code|
        traffic_price = strategy['base']['_traffic']
        query = { city: city_code, code: '_traffic' }
        TaxonItem.find_or_create_by!(query) { |e| e.price = traffic_price }

        Taxon.taxon_codes.each do |code|
          query = { city: city_code, code: code }
          TaxonItem.find_or_create_by!(query) do |item|
            item.price = strategy['items'][code]
          end
        end
      end
    end

    puts TaxonItem.count
    TaxonItem.all.each do |item|
      city = ChinaCity.get(item.city)
      item_name = Taxon.taxon_name(item.code)
      category = Taxon.category_name(item.code)
      puts "#{city}\t#{category}\t#{item_name}\t#{item.price}"
    end
  end
end
