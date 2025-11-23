# CVF Portfolio Company Portal - Part 2

A full-stack web application for managing CVF (Customer Value Financing) deals, built with Ruby on Rails, React/TypeScript, and MySQL.

## Architecture

This application consists of:
- **Backend**: Ruby on Rails 7.1 API with ActiveAdmin
- **Frontend**: React 18 with TypeScript and Vite
- **Database**: MySQL 8.0
- **Background Jobs**: Sidekiq with Redis
- **Containerization**: Docker and Docker Compose

## Prerequisites

- Docker and Docker Compose
- Git

## Quick Start

### 1. Clone the Repository

```bash
cd part2
```

### 2. Build and Start Services

```bash
docker-compose up --build
```

This will start all services:
- **web**: Rails API server (http://localhost:3000)
- **frontend**: React development server (http://localhost:5173)
- **db**: MySQL database
- **redis**: Redis for Sidekiq
- **worker**: Sidekiq worker for background jobs
- **scheduler**: Sidekiq scheduler for cron jobs

### 3. Set Up the Database

In a new terminal window:

```bash
# Run migrations
docker-compose exec web bundle exec rails db:create db:migrate

# Seed the database with sample data
docker-compose exec web bundle exec rails db:seed
```

### 4. Access the Application

- **Portfolio Company Portal**: http://localhost:5173
- **Admin Interface**: http://localhost:3000/admin
  - Email: admin@cvf.com
  - Password: password
- **Sidekiq Dashboard**: http://localhost:3000/sidekiq
- **API**: http://localhost:3000/api/v1

## Application Features

### For CVF Portfolio Companies

The main frontend application provides companies with:

1. **Dashboard**: Overview of all cohorts, investments, and returns
2. **Cohort Management**: View detailed cohort information including:
   - Financial overview (committed, adjustments, actual spend)
   - Monthly payment breakdowns
   - Threshold status
   - Progress toward cash cap
3. **Spend Management**: Update committed spend and adjustments for each cohort
4. **Transaction Upload**: Interface for uploading customer payment data

### For CVF Admins (ActiveAdmin)

The admin interface at `/admin` allows CVF staff to:

1. **Manage Organizations**: Create and edit portfolio companies
2. **Manage Funds**: Configure CVF funds
3. **Configure Fund-Organization Relationships**: Set:
   - Investment limits
   - Default share percentages
   - Prediction scenarios (WORST, AVERAGE, BEST)
   - Threshold configurations
4. **Manage Cohorts**: Create cohorts and manage state transitions:
   - New → Active → Completed → Settled/Terminated
5. **View Cohort Payments**: Monitor monthly payment status and collections

## Data Models

### Core Models

- **Organization**: Portfolio companies partnering with CVF
- **Fund**: CVF investment funds
- **FundOrganization**: Join table configuring the relationship between funds and organizations
- **Cohort**: Monthly investment cohorts with state machine (new/active/completed/settled/terminated)
- **Customer**: End customers of the organization
- **Txn**: Customer payment transactions
- **CohortPayment**: Monthly payment calculations per cohort

### Business Logic

#### Cohort States (AASM)
- **new**: Cohort created but not yet approved
- **active**: Funds distributed, cohort is active
- **completed**: Month ended, adjustment recorded
- **settled**: Cash cap reached
- **terminated**: Investment ended without reaching cap

#### Automatic Calculations

The system automatically:
1. **Calculates monthly revenue** from customer transactions
2. **Checks thresholds** against payment performance
3. **Adjusts share percentage** to 100% when thresholds are breached
4. **Applies cash caps** to limit total collections
5. **Updates cohort totals** when payments are recorded

#### Background Jobs

- **UpdateCohortPaymentJob**: Recalculates a specific month's payment when transactions are added
- **RecalculateCohortPaymentsJob**: Recalculates all months when spend is adjusted
- **FinalizeCohortPaymentsJob**: Daily cron job to finalize stable cohort payments

## API Endpoints

### Organizations
- `GET /api/v1/organizations` - List all organizations
- `GET /api/v1/organizations/:id` - Get organization details with stats

### Cohorts
- `GET /api/v1/organizations/:org_id/cohorts` - List cohorts for organization
- `GET /api/v1/organizations/:org_id/cohorts/:id` - Get cohort details
- `PATCH /api/v1/organizations/:org_id/cohorts/:id` - Update cohort (committed, adjustment)
- `POST /api/v1/organizations/:org_id/cohorts/:id/approve` - Approve cohort
- `POST /api/v1/organizations/:org_id/cohorts/:id/complete` - Complete cohort
- `POST /api/v1/organizations/:org_id/cohorts/:id/terminate` - Terminate cohort

### Cohort Payments
- `GET /api/v1/organizations/:org_id/cohorts/:cohort_id/cohort_payments` - List payments

### Transactions
- `GET /api/v1/organizations/:org_id/txns` - List transactions
- `POST /api/v1/organizations/:org_id/txns` - Create transaction

## Development

### Running Tests

```bash
# Rails tests
docker-compose exec web bundle exec rspec

# Frontend tests (when implemented)
docker-compose exec frontend npm test
```

### Rails Console

```bash
docker-compose exec web bundle exec rails console
```

### Database Console

```bash
docker-compose exec web bundle exec rails dbconsole
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web
docker-compose logs -f worker
docker-compose logs -f frontend
```

### Restart Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart web
```

## Project Structure

```
part2/
├── app/                    # Rails application
│   ├── admin/             # ActiveAdmin resources
│   ├── controllers/       # API controllers
│   ├── jobs/              # Sidekiq background jobs
│   ├── models/            # ActiveRecord models
│   └── serializers/       # API serializers
├── config/                # Rails configuration
├── db/                    # Database migrations and schema
├── frontend/              # React/TypeScript application
│   └── src/
│       ├── components/    # Reusable React components
│       ├── lib/          # API client and utilities
│       └── pages/        # Page components
├── docker-compose.yml     # Docker services configuration
├── Dockerfile.rails       # Rails container
├── Dockerfile.frontend    # Frontend container
└── README.md             # This file
```

## Design Decisions

### 1. Data Storage
- **MySQL database** for relational data with strong consistency guarantees
- **JSON columns** with StoreModel for flexible prediction scenarios and thresholds
- **Redis** for background job queues

### 2. Application Architecture
- **API-first design** with separate frontend and backend
- **Client-side rendering** for better UX and interactivity
- **Background jobs** for calculation-heavy operations
- **State machines (AASM)** for cohort and payment lifecycle management

### 3. User Experience
- **Read-only by default** with explicit edit modes for spend management
- **Automatic recalculation** when data changes
- **Clear visual indicators** for threshold breaches and payment status
- **Progressive disclosure** with summary views and detailed drill-downs

### 4. Continuous Updates
The system maintains consistency through:
- **Callbacks** on model changes (e.g., txn creation triggers payment recalculation)
- **Background jobs** for expensive calculations
- **Optimistic updates** in the frontend with React Query

### 5. Michelin-Star Service Approach
- **Simplicity**: Companies only need to update 3 numbers (committed, adjustment, transactions)
- **Transparency**: All calculations are visible and explained
- **Automation**: System handles all complex calculations
- **Guidance**: Clear instructions and validation feedback

## Troubleshooting

### Database Connection Issues
```bash
docker-compose down
docker-compose up --build
```

### Port Already in Use
Change ports in `docker-compose.yml` if 3000, 5173, or 3306 are already in use.

### Reset Database
```bash
docker-compose exec web bundle exec rails db:drop db:create db:migrate db:seed
```

## Production Considerations

For production deployment, you would need to:

1. **Security**:
   - Add authentication/authorization for API endpoints
   - Use environment variables for secrets
   - Enable HTTPS/SSL
   - Add rate limiting

2. **Performance**:
   - Add database indexes (already included in migrations)
   - Implement caching (Redis)
   - Use CDN for static assets
   - Optimize database queries with eager loading

3. **Monitoring**:
   - Add error tracking (Sentry, Rollbar)
   - Set up application monitoring (New Relic, DataDog)
   - Configure log aggregation
   - Set up alerts for failed background jobs

4. **Infrastructure**:
   - Use managed database (RDS, Cloud SQL)
   - Deploy with orchestration (Kubernetes, ECS)
   - Set up CI/CD pipeline
   - Configure auto-scaling

## License

This is a take-home assignment for CVF.
