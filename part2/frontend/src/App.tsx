import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import Layout from './components/Layout'
import ProtectedRoute from './components/ProtectedRoute'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import CohortList from './pages/CohortList'
import CohortDetail from './pages/CohortDetail'
import SpendManagement from './pages/SpendManagement'
import TransactionUpload from './pages/TransactionUpload'

function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="dashboard" element={<Dashboard />} />
            <Route path="cohorts" element={<CohortList />} />
            <Route path="cohorts/:id" element={<CohortDetail />} />
            <Route path="spend" element={<SpendManagement />} />
            <Route path="transactions" element={<TransactionUpload />} />
          </Route>
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  )
}

export default App
