class Taxon < ActiveRecord::Base
  class << self
    delegate :certified_statuses, :taxon_codes, :reason_codes, :items,
      :categories, :certified_status, :certify_failure_status?,
      :certify_success_status?, :certify_under_review_status?,
      to: "::Taxon::Config"
  end

  belongs_to :handyman
  belongs_to :certified_by, foreign_key: 'certified_by', class_name: 'Account'
  scope :pending, -> { where(state: 'under_review') }
  scope :certified, -> { where(state: 'success') }
  scope :declined, -> { where(state: 'failure') }
  alias_attribute :state, :certified_status
  alias_attribute :declined_at, :certified_at

  validates :handyman, presence: true
  validates :code, presence: true, uniqueness: { scope: :handyman }
  validates :certified_status, inclusion: { in: self.certified_statuses }
  validates :code, inclusion: { in: self.taxon_codes }
  validates :state, presence: true

  with_options if: :declined? do |v|
    v.validates :reason_message, presence: true
    v.validates :reason_code, presence: true
    v.validates :reason_code,
      inclusion: { in: self.reason_codes },
      allow_nil: true
  end

  with_options unless: :pending? do |v|
    v.validates! :certified_by, admin: { presence: true }
    v.validates! :certified_at, presence: true
  end

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

      'categories' => items.keys.map do |key|
        [ key, { 'code' => key, 'name' => Taxon.category_name(key) } ]
      end.to_h
    }
  end

  def self.taxons_for_grouped_select
    @@taxons_for_grouped_select ||= categories.map do |category|
      group = [ category_name(category), [] ]
      items[category].each do |taxon|
        group[1] << [ taxon_name(category, taxon), "#{category}/#{taxon}" ]
      end
      group
    end
  end

  def name
    @taxon_name ||= Taxon.taxon_name(code)
  end

  def category_name
    @category_name ||= Taxon.category_name(code.split('/').first)
  end

  def declined?
    self.class.certify_failure_status?(certified_status)
  end

  def certified?
    self.class.certify_success_status?(certified_status)
  end

  def pending?
    self.class.certify_under_review_status?(certified_status)
  end
end
