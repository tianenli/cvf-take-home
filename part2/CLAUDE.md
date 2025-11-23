# Architecture

The app will be a dockerized web application running Ruby on Rails as the web server, serving a client-side rendered React/Typescript frontend via vite.

Data should be stored in a mySQL database.

There should also be worker and scheduler instances to handle cron/asynchornous sidekiq jobs.

ActiveAdmin should also be setup for admins to go manage models that cannot be updated via frontend.

Ruby code should live in /app directory whiel frontend code should live in /frontend directory

# Models

## Organization

id 

name

## Fund

id

name

start_date

end_date

## fund_organizations join table

id

organization_id

fund_id

max_invest_per_cohort

max_total_invest

first_cohort_date

last_cohort_date

default_share_percentage

default_prediction_scenarios - Use ApplicationStoreModel and a  json column with array of scenarios / m0 / churn percent. Can be null and we should default to something in memory

default_thresholds - Similar to default_prediction_scenarios excepts contains the thresholds at which share_perentage will go to 100%

## Cohorts table

id

fund_organizations_id

cohort_start_date

share_percentage

status - AASM column with following states

    - new - has not been approved / funds have not been distributed

    - active - approved / funds being distributed for current cohort

    - completed - month is done and adjustment to reflect final spend has been inputted

    - settled- cash cap has been reached

    - terminated - investment is no longer returning but cash cap has not yet been reached

prediction_scenarios_override - can be null, in which case it defaults to fund_organizations’s values

thresholds_override - can be null, in which case it defaults to fund_organizations’s values

committed - amount of spend planned

adjustment - amount of spend 

cash_cap

total_returned

approved_at

completed_at

settled_at

terminated_at

## Customers table

id

reference_id - the org’s internal id for the customer

cohort_id - the cohort this particular customer of the org belongs to

## Txns Table

id

organization_id

customer_id

reference_id - org’s internal id for the transaction

payment_date

amount

## CohortPayments Table - keeps track of payments made by customers in each cohort per month and amount owed back

id

status - AASM column

    computing: txns are still being tabulated

    finalized: final amounts owed have been finalized

    settled: final amounts owed have been paid

cohort_id

months_after - months after cohort was acquired

total_revenue

threshold_hit

share_percentage

total_owed

total_paid

finalized_at

settled_at
