// WebSocket 管理器 — 实时聊天 + 通知推送
import { webSocket } from '@kit.NetworkKit'
import { getToken } from './ApiClient'
import { discoverServerIp } from '../common/ServerDiscovery'

export interface WsMessage {
  type: string
  id?: number
  senderId?: number
  receiverId?: number
  content?: string
  notificationType?: string
  relatedId?: number
  createdAt?: string
  message?: string
  userId?: number
}

interface WsSendData {
  type: string
  receiverId?: number
  content?: string
}

type MessageHandler = (msg: WsMessage) => void

export class WebSocketManager {
  private ws: webSocket.WebSocket | null = null
  private handlers: MessageHandler[] = []
  private reconnectTimer: number = -1
  private pingTimer: number = -1
  private url: string = ''
  private shouldReconnect: boolean = false

  /** 连接 WebSocket */
  async connect(): Promise<void> {
    await this.close()
    this.shouldReconnect = true

    try {
      const ip = await discoverServerIp()
      const token = getToken()
      this.url = `ws://${ip}:8080/ws/chat?token=${token}`
    } catch (_err) {
      this.scheduleReconnect()
      return
    }

    try {
      this.ws = webSocket.createWebSocket()

      this.ws.on('open', (_err: Object, _value: Object) => {
        this.startPing()
      })

      this.ws.on('message', (err: Object, value: string | ArrayBuffer) => {
        if (err) {
          return
        }
        try {
          let text: string
          if (typeof value === 'string') {
            text = value
          } else {
            // ArrayBuffer -> string (fallback, WebSocket text frames are always string)
            const buf: ArrayBuffer = value as ArrayBuffer
            const arr: Uint8Array = new Uint8Array(buf)
            text = ''
            for (let j = 0; j < arr.length; j++) {
              text += String.fromCharCode(arr[j])
            }
          }
          const msg: WsMessage = JSON.parse(text) as WsMessage
          for (let i = 0; i < this.handlers.length; i++) {
            this.handlers[i](msg)
          }
        } catch (_e) {
          // parse error, ignore
        }
      })

      this.ws.on('close', (_err: Object, _value: Object) => {
        this.stopPing()
        this.scheduleReconnect()
      })

      this.ws.on('error', (_err: Object) => {
        this.stopPing()
        this.scheduleReconnect()
      })

      this.ws.connect(this.url, (err: Object, _value: boolean) => {
        if (err) {
          this.scheduleReconnect()
        }
      })
    } catch (_err) {
      this.scheduleReconnect()
    }
  }

  /** 发送消息 */
  send(data: WsSendData): void {
    if (this.ws) {
      try {
        this.ws.send(JSON.stringify(data), (_err: Object) => {
          // ignore
        })
      } catch (_e) {
        // send failed, ignore
      }
    }
  }

  /** 发送聊天消息 */
  sendChat(receiverId: number, content: string): void {
    const data: WsSendData = { type: 'chat', receiverId, content }
    this.send(data)
  }

  /** 发送心跳 */
  sendPing(): void {
    const data: WsSendData = { type: 'ping' }
    this.send(data)
  }

  /** 注册消息处理器 */
  onMessage(handler: MessageHandler): void {
    this.handlers.push(handler)
  }

  /** 重置所有状态（切换账号时调用） */
  reset(): void {
    this.handlers = []
    this.close()
  }

  /** 移除消息处理器 */
  offMessage(handler: MessageHandler): void {
    const newHandlers: MessageHandler[] = []
    for (let i = 0; i < this.handlers.length; i++) {
      if (this.handlers[i] !== handler) {
        newHandlers.push(this.handlers[i])
      }
    }
    this.handlers = newHandlers
  }

  /** 关闭连接 */
  async close(): Promise<void> {
    this.shouldReconnect = false
    this.stopPing()
    this.stopReconnect()
    if (this.ws) {
      try {
        this.ws.close((_err: Object) => {
          // ignore
        })
      } catch (_e) {
        // ignore
      }
      this.ws = null
    }
  }

  private startPing(): void {
    this.stopPing()
    this.pingTimer = setInterval(() => {
      this.sendPing()
    }, 30000)
  }

  private stopPing(): void {
    if (this.pingTimer !== -1) {
      clearInterval(this.pingTimer)
      this.pingTimer = -1
    }
  }

  private scheduleReconnect(): void {
    if (!this.shouldReconnect) {
      return
    }
    this.stopReconnect()
    this.reconnectTimer = setTimeout(() => {
      this.connect()
    }, 3000)
  }

  private stopReconnect(): void {
    if (this.reconnectTimer !== -1) {
      clearTimeout(this.reconnectTimer)
      this.reconnectTimer = -1
    }
  }
}
