ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Recent Cohorts" do
          ul do
            Cohort.order(created_at: :desc).limit(10).map do |cohort|
              li link_to("#{cohort.organization.name} - #{cohort.cohort_start_date}", admin_cohort_path(cohort))
            end
          end
        end
      end

      column do
        panel "Statistics" do
          para "Total Organizations: #{Organization.count}"
          para "Total Funds: #{Fund.count}"
          para "Active Cohorts: #{Cohort.where(status: ['active', 'completed']).count}"
          para "Total Invested: $#{Cohort.where.not(status: 'new').sum(:committed).round(2)}"
          para "Total Returned: $#{Cohort.sum(:total_returned).round(2)}"
        end
      end
    end
  end
end
