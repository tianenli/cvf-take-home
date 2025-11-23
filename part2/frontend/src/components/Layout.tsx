import { Outlet, Link, useLocation } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export default function Layout() {
  const location = useLocation()
  const { user, logout } = useAuth()

  const isActive = (path: string) => {
    return location.pathname === path || location.pathname.startsWith(path + '/')
  }

  const navLinkClass = (path: string) =>
    `px-4 py-2 rounded-md text-sm font-medium transition-colors ${
      isActive(path)
        ? 'bg-primary-600 text-white'
        : 'text-gray-700 hover:bg-gray-100'
    }`

  const handleLogout = async () => {
    await logout()
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex">
              <div className="flex-shrink-0 flex items-center">
                <h1 className="text-2xl font-bold text-primary-600">CVF Portal</h1>
              </div>
              <div className="hidden sm:ml-8 sm:flex sm:space-x-4 items-center">
                <Link to="/dashboard" className={navLinkClass('/dashboard')}>
                  Dashboard
                </Link>
                <Link to="/cohorts" className={navLinkClass('/cohorts')}>
                  Cohorts
                </Link>
                <Link to="/spend" className={navLinkClass('/spend')}>
                  Spend Management
                </Link>
                <Link to="/transactions" className={navLinkClass('/transactions')}>
                  Transactions
                </Link>
              </div>
            </div>

            <div className="flex items-center space-x-4">
              <div className="text-sm text-gray-700">
                <p className="font-medium">{user?.name}</p>
                <p className="text-xs text-gray-500">{user?.organization_name}</p>
              </div>
              <button
                onClick={handleLogout}
                className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-md transition-colors"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet />
      </main>
    </div>
  )
}
