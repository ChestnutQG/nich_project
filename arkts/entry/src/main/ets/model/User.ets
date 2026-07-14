// 用户数据模型

export interface User {
  id: string
  nickname: string
  avatar: string
  phone: string
  role: string             // user | artisan | admin
  creditScore: number      // 信用分
  status: string           // active | frozen
  collectCount: number
  followCount: number
  orderCount: number
}

// 登录返回
export interface LoginResult {
  user: User
  token: string
}
