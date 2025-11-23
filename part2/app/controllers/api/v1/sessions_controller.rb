module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_dashboard_user!, only: [:create]

      def create
        user = DashboardUser.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          # Generate a simple token (in production, use JWT or similar)
          token = generate_token(user)

          render json: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              organization_id: user.organization_id,
              organization_name: user.organization.name
            }
          }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def destroy
        # In a real app, you'd invalidate the token here
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      def current
        render json: {
          user: {
            id: current_dashboard_user.id,
            email: current_dashboard_user.email,
            name: current_dashboard_user.name,
            organization_id: current_dashboard_user.organization_id,
            organization_name: current_dashboard_user.organization.name
          }
        }, status: :ok
      end

      private

      def generate_token(user)
        # Simple token for demo - in production use JWT
        payload = {
          user_id: user.id,
          organization_id: user.organization_id,
          exp: 24.hours.from_now.to_i
        }
        Base64.strict_encode64(payload.to_json)
      end
    end
  end
end
