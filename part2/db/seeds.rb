# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default admin user
AdminUser.create!(
  email: 'admin@cvf.com',
  password: 'password',
  password_confirmation: 'password'
) unless AdminUser.exists?(email: 'admin@cvf.com')

puts "Seeded admin user: admin@cvf.com / password"

# Create sample fund
fund = Fund.find_or_create_by!(name: 'CVF Fund I') do |f|
  f.start_date = Date.new(2020, 1, 1)
  f.end_date = Date.new(2030, 12, 31)
end

puts "Seeded fund: #{fund.name}"

# Create sample organization
org = Organization.find_or_create_by!(name: 'Sample Tech Company')

puts "Seeded organization: #{org.name}"

# Create fund organization relationship
fund_org = FundOrganization.find_or_create_by!(
  organization: org,
  fund: fund
) do |fo|
  fo.max_invest_per_cohort = 100_000
  fo.max_total_invest = 1_000_000
  fo.first_cohort_date = Date.new(2020, 1, 1)
  fo.last_cohort_date = Date.new(2025, 12, 31)
  fo.default_share_percentage = 20.0
  fo.default_prediction_scenarios = [
    { scenario: 'WORST', m0: 0.15, churn: 0.10 },
    { scenario: 'AVERAGE', m0: 0.25, churn: 0.05 },
    { scenario: 'BEST', m0: 0.35, churn: 0.02 }
  ]
  fo.default_thresholds = [
    { payment_period_month: 0, minimum_payment_percent: 0.15 },
    { payment_period_month: 1, minimum_payment_percent: 0.20 },
    { payment_period_month: 2, minimum_payment_percent: 0.18 },
    { payment_period_month: 3, minimum_payment_percent: 0.16 }
  ]
end

puts "Seeded fund organization relationship"
puts "\nSeeding complete!"
