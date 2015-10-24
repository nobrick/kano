module IdRandomizable
  extend ActiveSupport::Concern

  included do
    before_create :randomize_id
  end

  def randomize_id
    # Get model class with STI cases handling
    klass = case self.class
            when Handyman, User then Account
            else self.class
            end
    begin
      self.id = SecureRandom.random_number(2_100_000_000)
    end while klass.where(id: self.id).exists?
  end
end
