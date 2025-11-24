module Api
  module V1
    class CohortsController < BaseController
      before_action :set_cohort, only: [:show, :update, :submit, :approve, :complete, :terminate]

      def index
        authorize_organization!(params[:organization_id])

        @cohorts = current_organization.cohorts
          .includes(:cohort_payments)
          .order(cohort_start_date: :desc)

        render json: @cohorts, each_serializer: CohortSerializer
      end

      def show
        render json: @cohort, serializer: CohortDetailSerializer
      end

      def create
        authorize_organization!(params[:organization_id])

        # Find the appropriate fund_organization based on cohort_start_date
        cohort_start_date = Date.parse(cohort_create_params[:cohort_start_date])
        fund_organization = current_organization.fund_organizations
          .where('first_cohort_date <= ? AND last_cohort_date >= ?', cohort_start_date, cohort_start_date)
          .first!

        @cohort = fund_organization.cohorts.create!(cohort_create_params)
        render json: @cohort, serializer: CohortDetailSerializer, status: :created
      end

      def update
        if @cohort.new? || @cohort.submitted?
          # Update planned_spend when in new or submitted state
          @cohort.update!(planned_spend_params)
        elsif @cohort.approved?
          # Update actual_spend when in approved state
          if params[:cohort][:actual_spend].present?
            @cohort.set_actual_spend!(params[:cohort][:actual_spend])
          else
            @cohort.update!(cohort_update_params)
          end
        else
          @cohort.update!(cohort_update_params)
        end

        render json: @cohort, serializer: CohortDetailSerializer
      end

      def submit
        @cohort.submit!
        render json: @cohort, serializer: CohortDetailSerializer
      end

      def approve
        @cohort.approve!
        render json: @cohort, serializer: CohortDetailSerializer
      end

      def complete
        @cohort.complete!
        render json: @cohort, serializer: CohortDetailSerializer
      end

      def terminate
        @cohort.terminate!
        render json: @cohort, serializer: CohortDetailSerializer
      end

      private

      def set_cohort
        authorize_organization!(params[:organization_id])
        @cohort = current_organization.cohorts.find(params[:id])
        authorize_cohort!(@cohort.id)
      end

      def cohort_create_params
        params.require(:cohort).permit(:cohort_start_date, :planned_spend)
      end

      def planned_spend_params
        params.require(:cohort).permit(:planned_spend)
      end

      def cohort_update_params
        params.require(:cohort).permit(:planned_spend, :actual_spend)
      end
    end
  end
end
