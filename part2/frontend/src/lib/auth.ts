import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

export interface User {
  id: number
  email: string
  name: string
  organization_id: number
  organization_name: string
}

export interface LoginResponse {
  token: string
  user: User
}

export const authApi = {
  login: async (email: string, password: string): Promise<LoginResponse> => {
    const response = await axios.post(`${API_BASE_URL}/api/v1/login`, {
      email,
      password,
    })
    return response.data
  },

  logout: async (token: string): Promise<void> => {
    await axios.delete(`${API_BASE_URL}/api/v1/logout`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })
  },

  getCurrentUser: async (token: string): Promise<User> => {
    const response = await axios.get(`${API_BASE_URL}/api/v1/me`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })
    return response.data.user
  },
}

export const getToken = (): string | null => {
  return localStorage.getItem('cvf_token')
}

export const setToken = (token: string): void => {
  localStorage.setItem('cvf_token', token)
}

export const removeToken = (): void => {
  localStorage.removeItem('cvf_token')
}

export const getUser = (): User | null => {
  const userStr = localStorage.getItem('cvf_user')
  return userStr ? JSON.parse(userStr) : null
}

export const setUser = (user: User): void => {
  localStorage.setItem('cvf_user', JSON.stringify(user))
}

export const removeUser = (): void => {
  localStorage.removeItem('cvf_user')
}
