module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_dashboard_user!

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from UnauthorizedError, with: :unauthorized

      attr_reader :current_dashboard_user

      class UnauthorizedError < StandardError; end

      private

      def authenticate_dashboard_user!
        token = request.headers['Authorization']&.split(' ')&.last

        if token.blank?
          render json: { error: 'No token provided' }, status: :unauthorized
          return
        end

        begin
          payload = JSON.parse(Base64.strict_decode64(token))

          if Time.at(payload['exp']) < Time.now
            render json: { error: 'Token expired' }, status: :unauthorized
            return
          end

          @current_dashboard_user = DashboardUser.find(payload['user_id'])
        rescue => e
          render json: { error: 'Invalid token' }, status: :unauthorized
        end
      end

      def current_organization
        current_dashboard_user.organization
      end

      def authorize_organization!(organization_id)
        unless current_dashboard_user.organization_id == organization_id.to_i
          raise UnauthorizedError, "You don't have access to this organization"
        end
      end

      def authorize_cohort!(cohort_id)
        unless current_dashboard_user.has_access_to_cohort?(cohort_id)
          raise UnauthorizedError, "You don't have access to this cohort"
        end
      end

      def not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { error: exception.message, details: exception.record.errors }, status: :unprocessable_entity
      end

      def unauthorized(exception)
        render json: { error: exception.message }, status: :forbidden
      end
    end
  end
end
