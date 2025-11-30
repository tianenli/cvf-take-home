ActiveAdmin.register TransactionUpload do
  permit_params :organization_id, :csv_file

  index do
    selectable_column
    id_column
    column "Organization" do |upload|
      link_to upload.organization.name, admin_organization_path(upload.organization)
    end
    column :status do |upload|
      status_tag upload.status, class: upload.status
    end
    column :total_rows
    column :processed_rows
    column :failed_rows
    column "CSV File" do |upload|
      upload.csv_file.attached? ? upload.csv_file.filename : "N/A"
    end
    column :created_at
    actions
  end

  filter :organization
  filter :status, as: :select, collection: TransactionUpload.aasm.states.map(&:name)
  filter :created_at

  show do
    attributes_table do
      row :id
      row :organization
      row :status do |upload|
        status_tag upload.status, class: upload.status
      end
      row :total_rows
      row :processed_rows
      row :failed_rows
      row :processing_started_at
      row :processing_completed_at
      row :created_at
      row :updated_at
      row "CSV File" do |upload|
        if upload.csv_file.attached?
          link_to upload.csv_file.filename, rails_blob_path(upload.csv_file, disposition: "attachment")
        else
          "N/A"
        end
      end
      row :error_message if transaction_upload.error_message.present?
    end
  end

  form do |f|
    f.inputs do
      f.input :organization
      f.input :csv_file, as: :file, hint: "Upload CSV file with columns: customer_id, payment_date, amount, reference_id (optional)"
    end
    f.actions
  end
end
