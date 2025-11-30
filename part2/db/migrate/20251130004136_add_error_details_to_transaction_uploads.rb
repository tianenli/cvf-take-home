class AddErrorDetailsToTransactionUploads < ActiveRecord::Migration[7.2]
  def change
    add_column :transaction_uploads, :error_details, :json
  end
end
