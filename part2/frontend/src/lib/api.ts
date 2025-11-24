import axios from 'axios'
import { getToken } from './auth'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

export const api = axios.create({
  baseURL: `${API_BASE_URL}/api/v1`,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Add authorization header to all requests
api.interceptors.request.use((config) => {
  const token = getToken()
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Transform JSON API responses to plain objects
api.interceptors.response.use(
  (response) => {
    // If response has JSON API format, transform it
    if (response.data && response.data.data) {
      const data = response.data.data
      const included = response.data.included || []

      // Build a map of included resources by type and id
      const includedMap: Record<string, Record<string, any>> = {}
      included.forEach((item: any) => {
        if (!includedMap[item.type]) {
          includedMap[item.type] = {}
        }
        includedMap[item.type][item.id] = {
          id: item.id,
          ...item.attributes,
        }
      })

      // Helper to resolve relationships
      const resolveRelationships = (item: any) => {
        const resolved: any = {
          id: item.id,
          ...item.attributes,
        }

        // Handle relationships
        if (item.relationships) {
          Object.keys(item.relationships).forEach((key) => {
            const rel = item.relationships[key]
            if (rel.data) {
              if (Array.isArray(rel.data)) {
                // Has many relationship
                resolved[key] = rel.data.map((ref: any) =>
                  includedMap[ref.type]?.[ref.id] || { id: ref.id }
                )
              } else if (rel.data.type && rel.data.id) {
                // Belongs to relationship
                resolved[key] = includedMap[rel.data.type]?.[rel.data.id] || { id: rel.data.id }
              }
            }
          })
        }

        return resolved
      }

      // Handle arrays (list responses)
      if (Array.isArray(data)) {
        response.data = data.map(resolveRelationships)
      }
      // Handle single objects (show responses)
      else if (data.id && data.attributes) {
        response.data = resolveRelationships(data)
      }
    }

    return response
  },
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid, redirect to login
      localStorage.removeItem('cvf_token')
      localStorage.removeItem('cvf_user')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// Types
export interface Organization {
  id: number
  name: string
  created_at: string
  updated_at: string
}

export interface Cohort {
  id: number
  fund_organization_id: number
  cohort_start_date: string
  status: 'new' | 'submitted' | 'pending_approval' | 'approved' | 'pending_review' | 'completed' | 'settled' | 'terminated'
  share_percentage: number | null
  planned_spend: number
  actual_spend: number | null
  min_allowed_spend: number
  max_allowed_spend: number | null
  cash_cap: number | null
  adjusted_cash_cap: number | null
  effective_cash_cap: number | null
  total_returned: number
  progress_percentage: number
  approved_at: string | null
  completed_at: string | null
  settled_at: string | null
  terminated_at: string | null
  created_at: string
  updated_at: string
}

export interface CohortDetail extends Cohort {
  organization_name: string
  fund_name: string
  prediction_scenarios: PredictionScenario[]
  thresholds: Threshold[]
  cohort_payments: CohortPayment[]
}

export interface PredictionScenario {
  scenario: 'WORST' | 'AVERAGE' | 'BEST'
  m0: number
  churn: number
}

export interface Threshold {
  payment_period_month: number
  minimum_payment_percent: number
}

export interface CohortPayment {
  id: number
  cohort_id: number
  months_after: number
  status: 'computing' | 'finalized' | 'settled'
  total_revenue: number
  threshold_hit: boolean
  share_percentage: number
  total_owed: number
  total_paid: number
  outstanding_amount: number
  payment_percent_of_spend: number
  finalized_at: string | null
  settled_at: string | null
  created_at: string
  updated_at: string
}

export interface Txn {
  id: number
  organization_id: number
  customer_id: number
  reference_id: string
  payment_date: string
  amount: number
  months_after_cohort: number
  created_at: string
  updated_at: string
}

// API Functions
export const organizationsApi = {
  list: () => api.get<Organization[]>('/organizations'),
  get: (id: number) => api.get<Organization>(`/organizations/${id}`),
}

export const cohortsApi = {
  list: (organizationId: number) =>
    api.get<Cohort[]>(`/organizations/${organizationId}/cohorts`),
  get: (organizationId: number, id: number) =>
    api.get<CohortDetail>(`/organizations/${organizationId}/cohorts/${id}`),
  create: (organizationId: number, data: { cohort_start_date: string; planned_spend: number }) =>
    api.post<CohortDetail>(`/organizations/${organizationId}/cohorts`, { cohort: data }),
  update: (organizationId: number, id: number, data: Partial<Cohort>) =>
    api.patch<CohortDetail>(`/organizations/${organizationId}/cohorts/${id}`, { cohort: data }),
  submit: (organizationId: number, id: number) =>
    api.post<CohortDetail>(`/organizations/${organizationId}/cohorts/${id}/submit`),
  approve: (organizationId: number, id: number) =>
    api.post<CohortDetail>(`/organizations/${organizationId}/cohorts/${id}/approve`),
  complete: (organizationId: number, id: number) =>
    api.post<CohortDetail>(`/organizations/${organizationId}/cohorts/${id}/complete`),
  terminate: (organizationId: number, id: number) =>
    api.post<CohortDetail>(`/organizations/${organizationId}/cohorts/${id}/terminate`),
}

export const cohortPaymentsApi = {
  list: (organizationId: number, cohortId: number) =>
    api.get<CohortPayment[]>(`/organizations/${organizationId}/cohorts/${cohortId}/cohort_payments`),
}

export const txnsApi = {
  list: (organizationId: number) =>
    api.get<Txn[]>(`/organizations/${organizationId}/txns`),
  create: (organizationId: number, data: Partial<Txn>) =>
    api.post<Txn>(`/organizations/${organizationId}/txns`, { txn: data }),
}
