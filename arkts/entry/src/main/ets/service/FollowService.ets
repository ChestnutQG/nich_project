// 关注服务 — 对接 Spring Boot FollowController
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'
import { Artisan } from '../model/Artisan'

interface FollowReq {
  artisanId: number
}

export class FollowService {

  // 我关注的匠人列表
  static async fetchMyFollows(): Promise<ApiResponse<Artisan[]>> {
    const resp = await ApiClient.get<Artisan[]>('/follows')
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 关注匠人
  static async follow(artisanId: string): Promise<ApiResponse<null>> {
    const body: FollowReq = { artisanId: parseInt(artisanId) }
    return ApiClient.post<null>('/follows', body)
  }

  // 取消关注
  static async unfollow(artisanId: string): Promise<ApiResponse<null>> {
    return ApiClient.del<null>(`/follows/${artisanId}`)
  }
}
