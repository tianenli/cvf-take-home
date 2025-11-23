class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  def authenticate_admin_user!
    redirect_to new_admin_user_session_path unless admin_user_signed_in?
  end

  def current_admin_user
    @current_admin_user ||= AdminUser.find(session[:admin_user_id]) if session[:admin_user_id]
  end

  def admin_user_signed_in?
    current_admin_user.present?
  end

  helper_method :current_admin_user, :admin_user_signed_in?
end
