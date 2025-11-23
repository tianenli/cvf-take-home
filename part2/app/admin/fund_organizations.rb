ActiveAdmin.register FundOrganization do
  menu label: "Fund-Org Relationships"

  permit_params :organization_id, :fund_id, :max_invest_per_cohort, :max_total_invest,
                :first_cohort_date, :last_cohort_date, :default_share_percentage,
                :default_prediction_scenarios, :default_thresholds

  index do
    selectable_column
    id_column
    column :organization
    column :fund
    column :default_share_percentage
    column :max_invest_per_cohort
    column :max_total_invest
    column "Cohorts" do |fo|
      fo.cohorts.count
    end
    actions
  end

  filter :organization
  filter :fund
  filter :created_at

  show do
    attributes_table do
      row :id
      row :organization
      row :fund
      row :default_share_percentage
      row :max_invest_per_cohort
      row :max_total_invest
      row :first_cohort_date
      row :last_cohort_date
      row :default_prediction_scenarios do |fo|
        fo.default_prediction_scenarios&.map { |ps| "#{ps.scenario}: m0=#{ps.m0}, churn=#{ps.churn}" }&.join(', ')
      end
      row :default_thresholds do |fo|
        fo.default_thresholds&.map { |t| "M#{t.payment_period_month}: #{t.minimum_payment_percent}" }&.join(', ')
      end
      row :created_at
      row :updated_at
    end

    panel "Cohorts" do
      table_for fund_organization.cohorts.order(cohort_start_date: :desc) do
        column "Cohort Date" do |cohort|
          link_to cohort.cohort_start_date, admin_cohort_path(cohort)
        end
        column :status
        column :committed
        column :total_returned
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :organization
      f.input :fund
      f.input :default_share_percentage
      f.input :max_invest_per_cohort
      f.input :max_total_invest
      f.input :first_cohort_date, as: :datepicker
      f.input :last_cohort_date, as: :datepicker
    end
    f.actions
  end
end
