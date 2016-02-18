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
    %w{ success failure under_review }
  end

  def self.taxon_codes
    @@taxon_codes ||= taxons_config['items']
      .map { |c, l| l.map { |t| "#{c}/#{t}" } }.flatten
  end

  def self.reason_codes
    @@reason_codes ||= taxons_config['reason_codes']
  end

  def self.items
    @@items ||= taxons_config['items']
  end

  def self.categories
    @@categories ||= taxons_config['categories']
  end

  def self.certified_status(status)
    status
  end

  def self.certify_failure_status?(status)
    status == 'failure'
  end

  def self.certify_success_status?(status)
    status == 'success'
  end

  def self.certify_under_review_status?(status)
    status == 'under_review'
  end
end
