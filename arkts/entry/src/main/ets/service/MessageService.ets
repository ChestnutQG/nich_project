// 私信服务 — 对接 MessageController
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'

// 会话列表项
export interface Conversation {
  otherId: string
  otherName: string
  otherAvatar: string
  lastContent: string
  unread: number
  time: string
}

// 单条聊天消息
export interface ChatMessage {
  id: string
  fromMe: boolean
  content: string
  time: string
}

interface SendReq {
  toUserId: number
  content: string
}

export class MessageService {

  // 会话列表
  static async fetchConversations(): Promise<ApiResponse<Conversation[]>> {
    const resp = await ApiClient.get<Conversation[]>('/messages/conversations')
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 与某人的聊天记录（会自动标记已读）
  static async fetchChat(otherId: string): Promise<ApiResponse<ChatMessage[]>> {
    const resp = await ApiClient.get<ChatMessage[]>(`/messages/${otherId}`)
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 发私信
  static async send(toUserId: string, content: string): Promise<ApiResponse<number>> {
    const body: SendReq = { toUserId: parseInt(toUserId), content }
    return ApiClient.post<number>('/messages', body)
  }

  // 未读私信总数
  static async unreadCount(): Promise<number> {
    const resp = await ApiClient.get<number>('/messages/unread-count')
    return resp.code === 0 ? (resp.data as number || 0) : 0
  }
}
