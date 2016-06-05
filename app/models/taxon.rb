class Taxon < ActiveRecord::Base
  include Serializable

  class << self
    delegate :taxon_codes, :reason_codes, :items, :categories,
      :certified_status, :certified_statuses, to: '::Taxon::Config'
  end

  belongs_to :handyman
  belongs_to :certified_by, foreign_key: 'certified_by', class_name: 'Account'
  scope :pending, -> { where(state: 'under_review') }
  scope :certified, -> { where(state: 'success') }
  scope :declined, -> { where(state: 'failure') }
  scope :non_pending, -> { where.not(state: 'under_review') }
  scope :non_certified, -> { where.not(state: 'success') }
  scope :non_declined, -> { where.not(state: 'failure') }
  alias_attribute :state, :certified_status
  alias_attribute :declined_by, :certified_by
  alias_attribute :declined_at, :certified_at
  alias_attribute :requested_at, :cert_requested_at
  validates :handyman, presence: true
  validates :code, presence: true, uniqueness: { scope: :handyman },
    inclusion: { in: self.taxon_codes }
  validates :state, inclusion: { in: self.certified_statuses }
  validates :requested_at, presence: true, if: :pending?

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

  before_validation :touch_requested_at, if: :pending?

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

  def pending?
    state == 'under_review'
  end

  def declined?
    state == 'failure'
  end

  def certified?
    state == 'success'
  end

  def pend
    self.state = 'under_review'
    reset_reason
    reset_authorizer
    self.requested_at = Time.now
    self
  end

  def decline(options = {})
    self.state = 'failure'
    attrs = options.slice(:declined_by, :reason_code, :reason_message)
    assign_attributes(attrs)
    self.declined_at = Time.now
    self
  end

  def certify(options = {})
    self.state = 'success'
    assign_attributes(options.slice(:certified_by))
    reset_reason
    self.certified_at = Time.now
    self
  end

  def reason_code_desc
    I18n.t "taxon.reason_codes.#{reason_code}", default: :missing_info
  end

  private

  def set_reason(reason_code, reason_message)
    self.reason_code = reason_code
    self.reason_message = reason_message
  end

  def reset_reason
    self.reason_code = nil
    self.reason_message = nil
  end

  def reset_authorizer
    self.certified_by = nil
    self.certified_at = nil
  end

  def touch_requested_at
    self.requested_at ||= Time.now
  end
end
