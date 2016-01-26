class Handyman < Account
  include IdRandomizable

  has_many :orders
  has_many :taxons
  has_many :balance_records, -> { order(created_at: :desc) }, as: :owner

  with_options class_name: 'Order' do |v|
    v.has_many :finished_orders, -> { where(state: Order::FINISHED_STATES) }
    v.has_many :orders_paid_by_pingpp, -> { paid_by_pingpp }
    v.has_many :orders_paid_in_cash, -> { paid_in_cash }
  end

  has_one :latest_balance_record, -> { order(created_at: :desc) },
    class_name: 'BalanceRecord', as: :owner
  accepts_nested_attributes_for :taxons, allow_destroy: true
  validate :taxons_presence, on: :complete_info_context

  def handyman?
    true
  end

  def taxon_codes
    taxons.map(&:code)
  end

  def taxon_names
    taxons.map(&:name)
  end

  def taxons_redux_state
    {
      'result' => {
        'selectedTaxons' => taxon_codes,
        'taxons' => Taxon.taxon_codes
      },
      'entities' => Taxon.redux_entities
    }
  end

  def balance
    latest_balance_record.try(:balance) || 0
  end

  def cash_total
    latest_balance_record.try(:cash_total) || 0
  end

  private

  def taxons_presence
    errors.add(:base, '维修项目不能为空') if taxons.blank?
  end
end
