class Handyman < Account
  has_many :orders

  def handyman?
    true
  end
end
