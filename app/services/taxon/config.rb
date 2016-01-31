class Taxon::Config
  def self.taxons_config
    @@taxons_config ||= nil
    if @@taxons_config.nil?
      config_file = File.join('config','taxons.yml')
      config = YAML.load(File.read(config_file))
      @@taxons_config = config['taxons']
    end
    @@taxons_config
  end

  def self.certified_statuses
    @@certified_statuses ||= taxons_config['certified_status']
      .map { |k, v| v }
  end

  def self.taxon_codes
    @@taxon_codes ||= taxons_config['items']
      .map { |c, l| l.map { |t| "#{c}/#{t}" } }.flatten
  end

  def self.reason_codes
    @@reason_codes ||= taxons_config['reason_code']
  end

  def self.items
    @@items ||= taxons_config['items']
  end

  def self.categories
    @@categories ||= taxons_config['categories']
  end

  def self.certified_status(tmp_status)
    taxons_config['certified_status'][tmp_status]
  end

  def self.certify_failure_status?(tmp_status)
    tmp_status == taxons_config['certified_status']['failure']
  end

  def self.certify_success_status?(tmp_status)
    tmp_status == taxons_config['certified_status']['success']
  end

  def self.certify_under_review_status?(tmp_status)
    tmp_status == taxons_config['certified_status']['under_review']
  end

end
