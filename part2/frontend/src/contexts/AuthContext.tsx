import { createContext, useContext, useState, useEffect, ReactNode } from 'react'
import { User, authApi, getToken, setToken, removeToken, getUser, setUser, removeUser } from '../lib/auth'

interface AuthContextType {
  user: User | null
  token: string | null
  login: (email: string, password: string) => Promise<void>
  logout: () => Promise<void>
  isLoading: boolean
  isAuthenticated: boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUserState] = useState<User | null>(getUser())
  const [token, setTokenState] = useState<string | null>(getToken())
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const initAuth = async () => {
      const savedToken = getToken()
      const savedUser = getUser()

      if (savedToken && savedUser) {
        try {
          // Verify token is still valid
          const currentUser = await authApi.getCurrentUser(savedToken)
          setUserState(currentUser)
          setUser(currentUser)
          setTokenState(savedToken)
        } catch (error) {
          // Token is invalid, clear it
          removeToken()
          removeUser()
          setUserState(null)
          setTokenState(null)
        }
      }

      setIsLoading(false)
    }

    initAuth()
  }, [])

  const login = async (email: string, password: string) => {
    const response = await authApi.login(email, password)
    setToken(response.token)
    setUser(response.user)
    setUserState(response.user)
    setTokenState(response.token)
  }

  const logout = async () => {
    if (token) {
      try {
        await authApi.logout(token)
      } catch (error) {
        console.error('Logout error:', error)
      }
    }

    removeToken()
    removeUser()
    setUserState(null)
    setTokenState(null)
  }

  const value = {
    user,
    token,
    login,
    logout,
    isLoading,
    isAuthenticated: !!user && !!token,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
