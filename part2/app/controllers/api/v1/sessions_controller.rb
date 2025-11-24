module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_dashboard_user!, only: [:create]

      def create
        user = DashboardUser.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          # Generate JWT token using Warden::JWTAuth
          token = Warden::JWTAuth::UserEncoder.new.call(user, :dashboard_user, nil).first

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
        # Revoke the JWT token
        if current_dashboard_user
          # Add token to denylist
          token = request.headers['Authorization']&.gsub(/^Bearer /, '')
          if token
            begin
              jwt_payload = JWT.decode(
                token,
                ENV['DEVISE_JWT_SECRET_KEY'] || Rails.application.credentials.fetch(:devise_jwt_secret_key, SecureRandom.hex(64)),
                true,
                { algorithm: 'HS256' }
              ).first

              JwtDenylist.create!(
                jti: jwt_payload['jti'],
                exp: Time.at(jwt_payload['exp'])
              )
            rescue JWT::DecodeError
              # Token already invalid
            end
          end

          render json: { message: 'Logged out successfully' }, status: :ok
        else
          render json: { error: 'Not authenticated' }, status: :unauthorized
        end
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
    end
  end
end
