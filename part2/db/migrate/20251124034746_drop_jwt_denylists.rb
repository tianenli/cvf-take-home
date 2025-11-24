class DropJwtDenylists < ActiveRecord::Migration[7.2]
  def change
    drop_table :jwt_denylists do |t|
      t.string :jti
      t.datetime :exp
      t.timestamps
    end
  end
end
