// 认证服务 — 对接 Spring Boot UserController
import { User, LoginResult } from '../model/User'
import { ApiResponse } from '../model/ApiResponse'
import { ApiClient, saveToken, clearToken } from './ApiClient'

interface LoginReq {
  phone: string
  password: string
}

interface RegisterReq {
  username: string
  phone: string
  password: string
}

// eslint-disable-next-line @typescript-eslint/no-empty-interface
interface EmptyReq {}

export class AuthService {

  static async login(phone: string, password: string, remember: boolean = true): Promise<ApiResponse<LoginResult>> {
    const body: LoginReq = { phone, password }
    const resp = await ApiClient.post<LoginResult>('/users/login', body)
    if (resp.code === 0 && resp.data?.token) {
      await saveToken(resp.data.token, remember)
    }
    return resp
  }

  static async register(username: string, phone: string, password: string, remember: boolean = true): Promise<ApiResponse<LoginResult>> {
    const body: RegisterReq = { username, phone, password }
    const resp = await ApiClient.post<LoginResult>('/users/register', body)
    if (resp.code === 0 && resp.data?.token) {
      await saveToken(resp.data.token, remember)
    }
    return resp
  }

  static async getUserInfo(): Promise<ApiResponse<User>> {
    return await ApiClient.get<User>('/users/me')
  }

  static async logout(): Promise<ApiResponse<null>> {
    const empty: EmptyReq = {}
    await ApiClient.post<null>('/users/logout', empty)
    await clearToken()
    return { code: 0, message: 'ok', data: null }
  }

  /** 搜索用户（按昵称/手机号，用于找人聊天） */
  static async searchUsers(keyword: string): Promise<ApiResponse<User[]>> {
    const params: Record<string, string> = { 'keyword': keyword }
    return await ApiClient.get<User[]>('/users/search', params)
  }
}
