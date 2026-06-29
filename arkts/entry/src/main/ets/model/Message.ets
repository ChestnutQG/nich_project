// 消息模型 — 聊天消息 & 通知消息

export interface Message {
  id: number
  conversationId?: string      // 会话ID（聊天消息）
  senderId: number             // 发送者ID（0=系统）
  receiverId: number           // 接收者ID
  content: string              // 消息内容
  messageType: string          // 'chat' | 'notification'
  notificationType?: string    // dispute_new | dispute_status | dispute_resolved | jury_invite | system
  relatedId?: number           // 关联ID（维权ID等）
  isRead: boolean
  createdAt: string
  senderName?: string          // 发送者昵称
  senderAvatar?: string        // 发送者头像
}

// 获取通知类型的中文标签
export function getNotificationLabel(type: string | undefined): string {
  switch (type) {
    case 'dispute_new':
      return '🔔 维权提醒'
    case 'dispute_status':
      return '📋 状态更新'
    case 'dispute_resolved':
      return '⚖️ 裁决结果'
    case 'jury_invite':
      return '👨‍⚖️ 陪审邀请'
    case 'order_status':
      return '📦 订单动态'
    case 'artisan_new':
      return '🎨 匠人上新'
    case 'price_drop':
      return '💰 降价提醒'
    case 'system':
      return '📢 系统公告'
    default:
      return '🔔 消息通知'
  }
}

// 获取通知类型的图标
export function getNotificationIcon(type: string | undefined): string {
  switch (type) {
    case 'dispute_new':
      return '🔔'
    case 'dispute_status':
      return '📋'
    case 'dispute_resolved':
      return '⚖️'
    case 'jury_invite':
      return '👨‍⚖️'
    case 'order_status':
      return '📦'
    case 'artisan_new':
      return '🎨'
    case 'price_drop':
      return '💰'
    case 'system':
      return '📢'
    default:
      return '🔔'
  }
}
