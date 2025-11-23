import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Layout from './components/Layout'
import Dashboard from './pages/Dashboard'
import CohortList from './pages/CohortList'
import CohortDetail from './pages/CohortDetail'
import SpendManagement from './pages/SpendManagement'
import TransactionUpload from './pages/TransactionUpload'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="cohorts" element={<CohortList />} />
          <Route path="cohorts/:id" element={<CohortDetail />} />
          <Route path="spend" element={<SpendManagement />} />
          <Route path="transactions" element={<TransactionUpload />} />
        </Route>
      </Routes>
    </BrowserRouter>
  )
}

export default App
