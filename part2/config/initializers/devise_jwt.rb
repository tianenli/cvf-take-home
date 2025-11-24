# frozen_string_literal: true

Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = ENV['DEVISE_JWT_SECRET_KEY'] || Rails.application.credentials.fetch(:devise_jwt_secret_key, SecureRandom.hex(64))

    # Configure which requests will dispatch tokens (i.e., create new JWT tokens)
    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/login$}]
    ]

    # Configure which requests will revoke tokens (i.e., add to denylist)
    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/logout$}]
    ]

    # Token expiration time (24 hours)
    jwt.expiration_time = 24.hours.to_i
  end
end
