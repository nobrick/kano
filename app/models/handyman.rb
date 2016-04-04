class Handyman < Account
  has_many :orders
  has_many :taxons
  has_many :withdrawals
  has_many :balance_records, as: :owner

  with_options class_name: 'Order' do |v|
    v.has_many :finished_orders, -> { where(state: Order::FINISHED_STATES) }
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

  def taxons_redux_state
    {
      'result' => {
        'selectedTaxons' => taxon_codes(:pending),
        'taxons' => Taxon.taxon_codes - taxon_codes(:certified)
      },
      'entities' => Taxon.redux_entities
    }
  end

  def taxons_manage_redux_state
    {
      'result' => {
        'selectedTaxons' => taxon_codes,
        'taxons' => Taxon.taxon_codes - taxon_codes(:certified)
      },
      'entities' => Taxon.redux_entities
    }
  end

  def balance
    last_balance_record.try(:balance) || 0
  end

  def cash_total
    last_balance_record.try(:cash_total) || 0
  end

  def unfrozen_balance
    Withdrawal.unfrozen_balance_for(self)
  end

  private

  def taxons_presence
    errors.add(:base, '维修项目不能为空') if taxons.blank?
  end
end
