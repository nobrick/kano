class Handyman < Account
  has_many :orders
  has_many :taxons
  has_many :withdrawals
  has_many :balance_records, as: :owner

  with_options class_name: 'Order' do |v|
    v.has_many :finished_orders, -> { where(state: Order::FINISHED_STATES) }
    v.has_many :canceled_orders, -> { where(state: "canceled") }
    v.has_many :orders_under_processing, -> { where(state: Order::UNDER_PROCESSING_STATES) }
    v.has_many :orders_paid_by_pingpp, -> { paid_by_pingpp }
    v.has_many :orders_paid_in_cash, -> { paid_in_cash }
  end

  with_options class_name: 'BalanceRecord' do |v|
    v.belongs_to :last_balance_record
    v.has_one :unfrozen_balance_record,
      -> { where('created_at <= ?', Withdrawal.unfrozen_date) }, as: :owner
  end

  accepts_nested_attributes_for :taxons, allow_destroy: true
  validate :taxons_presence, on: :complete_info_context

  def handyman?
    true
  end

  def on_wechat?
    provider == 'handyman_wechat'
  end

  def certified?
    taxons.certified.any?
  end

  def taxon_codes(taxon_state = :all)
    case taxon_state.to_sym
    when :all
      taxons.map(&:code)
    else
      taxons.send(taxon_state).map(&:code)
    end
  end

  def taxon_names
    taxons.map(&:name)
  end

  def taxons_redux_state(options = {})
    selected = options.fetch(:selected_taxons, :pending)
    {
      'result' => {
        'selectedTaxons' => taxon_codes(selected),
        'taxons' => Taxon.taxon_codes - taxon_codes(:certified)
      },
      'entities' => Taxon.redux_entities
    }
  end

  def balance
    last_balance_record.try(:balance) || 0
  end

  def bonus_sum_total
    last_balance_record.try(:bonus_sum_total) || 0
  end

  def online_income_total
    last_balance_record.try(:online_income_total)
  end

  def online_income_total_without_bonus
    online_income_total - bonus_sum_total
  end

  def cash_total
    last_balance_record.try(:cash_total) || 0
  end

  def unfrozen_balance
    Withdrawal.unfrozen_balance_for(self)
  end

  def profit_per_order
    return 0 if orders_total == 0
    balance / orders_total
  end

  def finished_rate
    return "0%" if orders_total == 0
    "#{ Float(finished_orders.count) / orders_total * 100 }%"
  end

  def finished_orders_count_per_day
    time_interval = Date.current - created_at.to_date
    return 0 if time_interval == 0
    (Float(orders_total) / time_interval).round(3)
  end

  def orders_total
    orders.count
  end

  private

  def taxons_presence
    errors.add(:base, '维修项目不能为空') if taxons.blank?
  end
end
