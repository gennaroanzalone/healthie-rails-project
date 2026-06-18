class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      # The composite index below covers provider_id-first lookups, so skip the
      # auto-generated single-column index on provider_id to avoid redundancy.
      t.references :provider, null: false, foreign_key: true, index: false
      t.references :client, null: false, foreign_key: true
      t.string :plan, null: false

      t.timestamps
    end
    add_index :memberships, [ :provider_id, :client_id ], unique: true
  end
end
