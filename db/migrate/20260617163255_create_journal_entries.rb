class CreateJournalEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_entries do |t|
      # The composite index below covers client_id-first lookups, so skip the
      # auto-generated single-column index on client_id to avoid redundancy.
      t.references :client, null: false, foreign_key: true, index: false
      t.text :body, null: false

      t.timestamps
    end
    add_index :journal_entries, [ :client_id, :created_at ]
  end
end
