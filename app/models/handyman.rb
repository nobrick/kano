class Handyman < Account
  has_many :orders
  has_many :balance_records, -> { order(created_at: :desc) }, as: :owner
  has_one :latest_balance_record, -> { order(created_at: :desc) },
    class_name: 'BalanceRecord', as: :owner
  # TODO Flush balance record related associations cache automatically whenever
  # getting touched.
  #
  # after_touch :clear_association_cache

  def handyman?
    true
  end
end
