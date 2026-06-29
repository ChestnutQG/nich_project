// 消息服务 — 聊天 & 通知 API
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'
import { Message } from '../model/Message'

interface UnreadCount {
  total: number
  chat: number
  notification: number
}

interface SendChatReq {
  receiverId: number
  content: string
}

export class MessageService {

  // ==================== 聊天 ====================

  /** 发送聊天消息（HTTP 方式，WebSocket 也可用） */
  static async sendChatMessage(receiverId: number, content: string): Promise<ApiResponse<Message>> {
    const body: SendChatReq = { receiverId, content }
    return await ApiClient.post<Message>('/messages/chat', body)
  }

  /** 获取与某用户的聊天记录 */
  static async getChatMessages(peerId: number, page: number = 1, pageSize: number = 50): Promise<ApiResponse<Message[]>> {
    const params: Record<string, string> = {
      'page': String(page),
      'pageSize': String(pageSize)
    }
    return await ApiClient.get<Message[]>(`/messages/chat/${peerId}`, params)
  }

  /** 获取会话列表 */
  static async getConversations(): Promise<ApiResponse<Message[]>> {
    return await ApiClient.get<Message[]>('/messages/conversations')
  }

  /** 标记会话已读 */
  static async markConversationRead(peerId: number): Promise<ApiResponse<null>> {
    const emptyReq: Record<string, string> = {}
    return await ApiClient.put<null>(`/messages/chat/${peerId}/read`, emptyReq)
  }

  // ==================== 通知 ====================

  /** 获取通知列表 */
  static async getNotifications(page: number = 1, pageSize: number = 20): Promise<ApiResponse<Message[]>> {
    const params: Record<string, string> = {
      'page': String(page),
      'pageSize': String(pageSize)
    }
    return await ApiClient.get<Message[]>('/messages/notifications', params)
  }

  /** 标记某条通知已读 */
  static async markNotificationRead(id: number): Promise<ApiResponse<null>> {
    const emptyReq: Record<string, string> = {}
    return await ApiClient.put<null>(`/messages/notification/${id}/read`, emptyReq)
  }

  /** 全部通知标为已读 */
  static async markAllNotificationsRead(): Promise<ApiResponse<null>> {
    const emptyReq: Record<string, string> = {}
    return await ApiClient.put<null>('/messages/notifications/read-all', emptyReq)
  }

  // ==================== 未读数 ====================

  /** 获取未读消息数（总、聊天、通知） */
  static async getUnreadCount(): Promise<ApiResponse<UnreadCount>> {
    return await ApiClient.get<UnreadCount>('/messages/unread-count')
  }
}
