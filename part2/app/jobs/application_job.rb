class ApplicationJob
  include Sidekiq::Job

  # Global job configuration
  sidekiq_options retry: 3
end
