class DeviseCreateDashboardUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Organization association
      t.references :organization, null: false, foreign_key: true

      t.string :name

      t.timestamps null: false
    end

    add_index :dashboard_users, :email,                unique: true
    add_index :dashboard_users, :reset_password_token, unique: true
  end
end
