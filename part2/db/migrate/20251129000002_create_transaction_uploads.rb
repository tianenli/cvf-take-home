class CreateTransactionUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_uploads do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :status, null: false, default: 'submitted'
      t.text :error_message
      t.integer :total_rows
      t.integer :processed_rows
      t.integer :failed_rows
      t.datetime :processing_started_at
      t.datetime :processing_completed_at

      t.timestamps
    end

    add_index :transaction_uploads, :status
    add_index :transaction_uploads, :created_at
  end
end
