ActiveAdmin.register CohortPayment do
  menu label: "Cohort Payments"

  permit_params :cohort_id, :months_after, :total_paid

  index do
    selectable_column
    id_column
    column "Organization" do |cp|
      link_to cp.organization.name, admin_organization_path(cp.organization)
    end
    column "Cohort" do |cp|
      link_to cp.cohort.cohort_start_date, admin_cohort_path(cp.cohort)
    end
    column :months_after
    column :status
    column :total_revenue
    column :threshold_hit
    column :total_owed
    column :total_paid
    column "Outstanding" do |cp|
      number_to_currency(cp.total_owed - cp.total_paid)
    end
    actions
  end

  filter :cohort
  filter :status, as: :select, collection: CohortPayment.aasm.states.map(&:name)
  filter :months_after
  filter :threshold_hit
  filter :created_at

  show do
    attributes_table do
      row :id
      row :cohort
      row :months_after
      row :status
      row :total_revenue
      row :threshold_hit
      row :share_percentage
      row :total_owed
      row :total_paid
      row :finalized_at
      row :settled_at
      row :created_at
      row :updated_at
    end

    panel "Actions" do
      if cohort_payment.may_finalize?
        button_to "Finalize", finalize_admin_cohort_payment_path(cohort_payment), method: :post
      end
      if cohort_payment.may_settle?
        button_to "Settle", settle_admin_cohort_payment_path(cohort_payment), method: :post
      end
    end
  end

  member_action :finalize, method: :post do
    resource.finalize!
    redirect_to admin_cohort_payment_path(resource), notice: "Payment finalized"
  end

  member_action :settle, method: :post do
    resource.settle!
    redirect_to admin_cohort_payment_path(resource), notice: "Payment settled"
  end

  form do |f|
    f.inputs do
      f.input :cohort
      f.input :months_after
      f.input :total_paid
    end
    f.actions
  end
end
