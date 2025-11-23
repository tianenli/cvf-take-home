class CreateFunds < ActiveRecord::Migration[7.1]
  def change
    create_table :funds do |t|
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date

      t.timestamps
    end

    add_index :funds, :name
    add_index :funds, :start_date
  end
end
