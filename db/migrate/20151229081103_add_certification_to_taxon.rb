class AddCertificationToTaxon < ActiveRecord::Migration
  def change
    add_column :taxons, :certified_status, :string, default: "under_review"
    add_column :taxons, :cert_requested_at, :datetime
    add_column :taxons, :certified_at, :datetime
    add_column :taxons, :certified_by, :integer
    add_column :taxons, :reason_code, :string
    add_column :taxons, :reason_message, :string
  end
end
