// 用户公开主页服务 — 对接 UserController /{id}/profile
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'

export interface PublicProfile {
  id: string
  nickname: string
  avatar: string
  role: string
  isArtisan: boolean
  // 以下仅当 isArtisan=true 时有值
  artisanId?: string
  title?: string
  intro?: string
  craftType?: string
  level?: number
  province?: string
  city?: string
  worksCount?: number
  followersCount?: number
  isFollowed?: boolean
}

interface IntroReq {
  intro: string
}

export class UserProfileService {

  static async fetchProfile(userId: string): Promise<ApiResponse<PublicProfile | undefined>> {
    const resp = await ApiClient.get<PublicProfile>(`/users/${userId}/profile`)
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: undefined }
  }

  // 修改自己的匠人简介
  static async updateMyIntro(intro: string): Promise<ApiResponse<null>> {
    const body: IntroReq = { intro }
    return ApiClient.put<null>('/artisans/me/intro', body)
  }
}
