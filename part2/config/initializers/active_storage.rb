Rails.application.config.after_initialize do
  # Create S3 bucket in LocalStack if it doesn't exist
  if Rails.env.development? && ENV['S3_ENDPOINT'].present?
    begin
      require 'aws-sdk-s3'

      s3_client = Aws::S3::Client.new(
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: ENV['AWS_REGION'],
        endpoint: ENV['S3_ENDPOINT'],
        force_path_style: true
      )

      bucket_name = ENV['S3_BUCKET']

      # Check if bucket exists, create if not
      begin
        s3_client.head_bucket(bucket: bucket_name)
        Rails.logger.info "S3 bucket '#{bucket_name}' already exists"
      rescue Aws::S3::Errors::NotFound
        s3_client.create_bucket(bucket: bucket_name)
        Rails.logger.info "Created S3 bucket '#{bucket_name}'"
      rescue => e
        Rails.logger.warn "Could not check/create S3 bucket: #{e.message}"
      end
    rescue => e
      Rails.logger.warn "Could not initialize S3: #{e.message}"
    end
  end
end
