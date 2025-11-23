module Api
  module V1
    class FundOrganizationsController < BaseController
      def index
        @fund_organizations = FundOrganization.includes(:organization, :fund).all
        render json: @fund_organizations, each_serializer: FundOrganizationSerializer
      end

      def show
        @fund_organization = FundOrganization.find(params[:id])
        render json: @fund_organization, serializer: FundOrganizationSerializer
      end

      def update
        @fund_organization = FundOrganization.find(params[:id])
        @fund_organization.update!(fund_organization_params)
        render json: @fund_organization, serializer: FundOrganizationSerializer
      end

      private

      def fund_organization_params
        params.require(:fund_organization).permit(
          :default_share_percentage,
          :max_invest_per_cohort,
          :max_total_invest,
          :first_cohort_date,
          :last_cohort_date
        )
      end
    end
  end
end
