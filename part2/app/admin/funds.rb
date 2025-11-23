ActiveAdmin.register Fund do
  permit_params :name, :start_date, :end_date

  index do
    selectable_column
    id_column
    column :name
    column :start_date
    column :end_date
    column "Organizations" do |fund|
      fund.organizations.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :start_date
  filter :end_date
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :start_date
      row :end_date
      row :created_at
      row :updated_at
    end

    panel "Organization Relationships" do
      table_for fund.fund_organizations do
        column "Organization" do |fo|
          link_to fo.organization.name, admin_organization_path(fo.organization)
        end
        column :default_share_percentage
        column :max_invest_per_cohort
        column :max_total_invest
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
    end
    f.actions
  end
end
