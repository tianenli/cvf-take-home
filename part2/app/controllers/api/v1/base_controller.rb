module Api
  module V1
    class BaseController < ActionController::API
      class UnauthorizedError < StandardError; end

      include ActionController::MimeResponds

      respond_to :json
      before_action :authenticate_dashboard_user!

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from UnauthorizedError, with: :unauthorized

      private

      def authenticate_dashboard_user!
        # Use Warden/Devise for JWT authentication
        unless current_dashboard_user
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def current_dashboard_user
        # Use Devise's current_user method with custom scope
        @current_dashboard_user ||= current_dashboard_user_from_jwt
      end

      def current_dashboard_user_from_jwt
        # Extract JWT from Authorization header
        token = request.headers['Authorization']&.gsub(/^Bearer /, '')
        return nil unless token

        begin
          # Use Warden::JWTAuth to decode the token (uses same secret as encoding)
          payload = Warden::JWTAuth::TokenDecoder.new.call(token)

          # Find user from sub claim
          user_id = payload['sub']
          user = DashboardUser.find(user_id)

          # JtiMatcher strategy: verify token's jti matches user's current jti
          return nil unless user.jti == payload['jti']

          @current_dashboard_user ||= user
        rescue Warden::JWTAuth::Errors::RevokedToken, JWT::DecodeError, ActiveRecord::RecordNotFound
          nil
        end
      end

      def current_organization
        current_dashboard_user&.organization
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
