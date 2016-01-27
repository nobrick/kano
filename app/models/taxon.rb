class Taxon < ActiveRecord::Base
  belongs_to :handyman
  belongs_to :certified_by, -> { where(admin: true) }, foreign_key: "certified_by", class_name: "Account"

  validates :handyman, presence: true
  validates :code, presence: true, uniqueness: { scope: :handyman }
  validates :reason_code, presence: true, if: :failure_status?

  def self.taxons_config
    @@taxons_config ||= nil
    if @@taxons_config.nil?
      config_file = File.join('config','taxons.yml')
      config = YAML.load(File.read(config_file))
      @@taxons_config = config['taxons']
    end
    @@taxons_config
  end

  def self.taxon_codes
    @@taxon_codes ||= taxons_config['items']
      .map { |c, l| l.map { |t| "#{c}/#{t}" } }.flatten
  end

  def self.certified_status
    @@taxon_certified_status ||= taxons_config['certified_status']
      .map { |k, v| v }
  end

  def self.certified_status_code(tmp_status)
    taxons_config['certified_status'][tmp_status]
  end

  def self.reason_codes
    @@taxon_reason_code ||= taxons_config['reason_code']
  end

  # TODO use the other model to implement taxon_codes taxons_config certified_status method
  validates_inclusion_of :code, in: self.taxon_codes
  validates_inclusion_of :certified_status, in: self.certified_status
  validates_inclusion_of :reason_code, in: self.reason_codes, allow_blank: true

  # Usage1: taxon_name(category, taxon)
  # Usage2: taxon_name(taxon)
  # Examples:
  #   taxon_name('electronic', 'lighting')
  #   taxon_name('electronic/lighting')
  def self.taxon_name(category_or_taxon, taxon = nil)
    category = nil
    if taxon.nil?
      category, taxon = category_or_taxon.split('/')
    else
      category = category_or_taxon
    end
    I18n.t("taxons.items.#{category}.#{taxon}", default: category_or_taxon)
  end

  def self.category_name(category_or_taxon)
    category = category_or_taxon.split('/').first
    I18n.t("taxons.categories.#{category}", default: category)
  end

  def self.taxons_for_grouped_select
    @@taxons_for_grouped_select ||= taxons_config['categories'].map do |category|
      group = [ category_name(category), [] ]
      taxons_config['items'][category].each do |taxon|
        group[1] << [ taxon_name(category, taxon), "#{category}/#{taxon}" ]
      end
      group
    end
  end

  def self.redux_entities
    @@redux_entities ||= {
      'taxons' => taxon_codes.map do |key|
        [ key, {
            'code' => key,
            'name' => taxon_name(key),
            'category' => key.split('/').first
          }
        ]
      end.to_h,

      'categories' => taxons_config['items'].keys.map do |key|
        [ key, { 'code' => key, 'name' => Taxon.category_name(key) } ]
      end.to_h
    }
  end

  def name
    @taxon_name ||= Taxon.taxon_name(code)
  end

  def category_name
    @category_name ||= Taxon.category_name(code.split('/').first)
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

  def failure_status?
    Taxon.certify_failure_status?(certified_status)
  end
end
