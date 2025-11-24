class AddJtiToDashboardUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :dashboard_users, :jti, :string, null: false
    add_index :dashboard_users, :jti, unique: true
  end
end
