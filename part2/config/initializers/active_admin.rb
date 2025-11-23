ActiveAdmin.setup do |config|
  config.site_title = "CVF Admin"
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user
  config.logout_link_path = :destroy_admin_user_session_path
  config.logout_link_method = :delete
  config.root_to = 'dashboard#index'
  config.batch_actions = true
  config.filter_attributes = [:encrypted_password, :password, :password_confirmation]
  config.localize_format = :long
  config.namespace :admin do |admin|
    admin.build_menu :utility_navigation do |menu|
      menu.add label: proc { "#{current_admin_user.email}" }, url: '#', id: 'current_user', if: proc { current_admin_user? }
      admin.add_logout_button_to_menu menu
    end
  end
end
