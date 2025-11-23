ActiveAdmin.register Organization do
  permit_params :name

  index do
    selectable_column
    id_column
    column :name
    column :created_at
    column "Active Cohorts" do |org|
      org.cohorts.where(status: ['active', 'completed']).count
    end
    column "Total Invested" do |org|
      number_to_currency(org.cohorts.where.not(status: 'new').sum(:committed))
    end
    actions
  end

  filter :name
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :created_at
      row :updated_at
    end

    panel "Fund Relationships" do
      table_for organization.fund_organizations do
        column "Fund" do |fo|
          link_to fo.fund.name, admin_fund_path(fo.fund)
        end
        column :default_share_percentage
        column :max_invest_per_cohort
        column :max_total_invest
        column :first_cohort_date
        column :last_cohort_date
      end
    end

    panel "Cohorts" do
      table_for organization.cohorts.order(cohort_start_date: :desc) do
        column "Cohort Date" do |cohort|
          link_to cohort.cohort_start_date, admin_cohort_path(cohort)
        end
        column :status
        column :committed
        column :total_returned
        column :cash_cap
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end
end
