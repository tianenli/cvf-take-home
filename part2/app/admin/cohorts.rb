ActiveAdmin.register Cohort do
  permit_params :fund_organization_id, :cohort_start_date, :share_percentage, :committed,
                :adjustment, :cash_cap, :prediction_scenarios_override, :thresholds_override

  index do
    selectable_column
    id_column
    column "Organization" do |cohort|
      link_to cohort.organization.name, admin_organization_path(cohort.organization)
    end
    column :cohort_start_date
    column :status
    column :committed
    column :adjustment
    column :total_returned
    column :cash_cap
    column "Progress" do |cohort|
      number_to_percentage((cohort.total_returned / cohort.cash_cap * 100), precision: 1)
    end
    actions
  end

  filter :fund_organization
  filter :status, as: :select, collection: Cohort.aasm.states.map(&:name)
  filter :cohort_start_date
  filter :created_at

  show do
    attributes_table do
      row :id
      row :organization
      row :fund
      row :cohort_start_date
      row :status
      row :share_percentage
      row :committed
      row :adjustment
      row :actual_spend
      row :cash_cap
      row :total_returned
      row :approved_at
      row :completed_at
      row :settled_at
      row :terminated_at
      row :created_at
      row :updated_at
    end

    panel "Cohort Payments" do
      table_for cohort.cohort_payments.order(:months_after) do
        column :months_after
        column :status
        column :total_revenue
        column :threshold_hit
        column :share_percentage
        column :total_owed
        column :total_paid
        column "% of Spend" do |cp|
          number_to_percentage(cp.payment_percent_of_spend, precision: 2)
        end
      end
    end

    panel "State Transitions" do
      if cohort.may_approve?
        button_to "Approve", approve_admin_cohort_path(cohort), method: :post, data: { confirm: "Are you sure?" }
      end
      if cohort.may_complete?
        button_to "Complete", complete_admin_cohort_path(cohort), method: :post, data: { confirm: "Are you sure?" }
      end
      if cohort.may_settle?
        button_to "Settle", settle_admin_cohort_path(cohort), method: :post, data: { confirm: "Are you sure?" }
      end
      if cohort.may_terminate?
        button_to "Terminate", terminate_admin_cohort_path(cohort), method: :post, data: { confirm: "Are you sure?" }
      end
    end
  end

  member_action :approve, method: :post do
    resource.approve!
    redirect_to admin_cohort_path(resource), notice: "Cohort approved"
  end

  member_action :complete, method: :post do
    resource.complete!
    redirect_to admin_cohort_path(resource), notice: "Cohort completed"
  end

  member_action :settle, method: :post do
    resource.settle!
    redirect_to admin_cohort_path(resource), notice: "Cohort settled"
  end

  member_action :terminate, method: :post do
    resource.terminate!
    redirect_to admin_cohort_path(resource), notice: "Cohort terminated"
  end

  form do |f|
    f.inputs do
      f.input :fund_organization
      f.input :cohort_start_date, as: :datepicker
      f.input :share_percentage
      f.input :committed
      f.input :adjustment
      f.input :cash_cap
    end
    f.actions
  end
end
