class Taxon < ActiveRecord::Base
  belongs_to :handyman

  validates :handyman, presence: true
  validates :code, presence: true, uniqueness: { scope: :handyman }
  # TODO validates :code inclusion
end
