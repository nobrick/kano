class RenameEstablishedAtToContractedAtOnOrder < ActiveRecord::Migration
  def change
    rename_column :orders, :established_at, :contracted_at
  end
end
