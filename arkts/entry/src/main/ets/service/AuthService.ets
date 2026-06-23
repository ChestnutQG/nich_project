// 认证服务（当前使用 Mock，后续替换为真实认证）
import { User } from '../model/User'
import { ApiResponse } from '../model/ApiResponse'

function delay(ms: number = 500): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

const mockUser: User = {
  id: 'u001',
  nickname: '非遗爱好者小明',
  avatar: 'https://picsum.photos/seed/user01/200/200',
  phone: '138****8888',
  collectCount: 12,
  followCount: 5,
  orderCount: 8
}

export class AuthService {
  static async login(phone: string, code: string): Promise<ApiResponse<User>> {
    await delay()
    return { code: 0, message: 'ok', data: mockUser }
  }

  static async getUserInfo(): Promise<ApiResponse<User>> {
    await delay(200)
    return { code: 0, message: 'ok', data: mockUser }
  }

  static async logout(): Promise<ApiResponse<null>> {
    await delay(200)
    return { code: 0, message: 'ok', data: null }
  }
}
