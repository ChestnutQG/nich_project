// 系统通知服务 — 对接 NotificationController
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'

export interface NotificationItem {
  id: string
  type: string
  title: string
  content: string
  refId: string
  isRead: boolean
  time: string
}

// PUT 无请求体时用的占位对象（ArkTS 不允许裸 {}）
interface EmptyBody {}
const EMPTY: EmptyBody = {}

export class NotificationService {

  static async fetchList(): Promise<ApiResponse<NotificationItem[]>> {
    const resp = await ApiClient.get<NotificationItem[]>('/notifications')
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  static async unreadCount(): Promise<number> {
    const resp = await ApiClient.get<number>('/notifications/unread-count')
    return resp.code === 0 ? (resp.data as number || 0) : 0
  }

  static async markRead(id: string): Promise<ApiResponse<null>> {
    return ApiClient.put<null>(`/notifications/${id}/read`, EMPTY)
  }

  static async markAllRead(): Promise<ApiResponse<null>> {
    return ApiClient.put<null>('/notifications/read-all', EMPTY)
  }
}
