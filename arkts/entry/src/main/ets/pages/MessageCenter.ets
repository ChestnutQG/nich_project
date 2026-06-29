// 消息中心 — 对话列表 + 通知列表
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Message, getNotificationIcon, getNotificationLabel } from '../model/Message'
import { User } from '../model/User'
import { MessageService } from '../service/MessageService'
import { AuthService } from '../service/AuthService'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct MessageCenter {
  @State currentTab: number = 0           // 0=对话, 1=通知
  @State conversations: Message[] = []
  @State notifications: Message[] = []
  @State loadingChat: boolean = true
  @State loadingNotif: boolean = true
  @State unreadChat: number = 0
  @State unreadNotif: number = 0
  @State currentUserId: number = 0
  @State refreshing: boolean = false
  @State showSearch: boolean = false      // 是否显示用户搜索
  @State searchKeyword: string = ''
  @State searchResults: User[] = []
  @State searchingUsers: boolean = false
  private pollTimer: number = -1

  aboutToAppear(): void {
    this.loadAll()
    this.startPolling()
  }

  onPageShow(): void {
    this.loadAll()
    this.startPolling()
  }

  onPageHide(): void {
    this.stopPolling()
  }

  startPolling(): void {
    if (this.pollTimer !== -1) return
    this.pollTimer = setInterval(() => {
      // 只刷新当前 tab 的数据，不显示 loading
      if (this.currentTab === 0) {
        this.loadConversations()
      } else {
        this.loadNotifications()
      }
      this.loadUnreadCount()
    }, 8000) // 每 8 秒刷新
  }

  stopPolling(): void {
    if (this.pollTimer !== -1) {
      clearInterval(this.pollTimer)
      this.pollTimer = -1
    }
  }

  async loadAll(): Promise<void> {
    // 获取当前用户ID
    const userResp = await AuthService.getUserInfo()
    if (userResp.code === 0 && userResp.data) {
      this.currentUserId = Number(userResp.data.id) || 0
    }
    await Promise.all([
      this.loadConversations(),
      this.loadNotifications(),
      this.loadUnreadCount()
    ])
  }

  async loadConversations(): Promise<void> {
    this.loadingChat = true
    const resp = await MessageService.getConversations()
    if (resp.code === 0) {
      this.conversations = resp.data || []
    }
    this.loadingChat = false
  }

  async loadNotifications(): Promise<void> {
    this.loadingNotif = true
    const resp = await MessageService.getNotifications(1, 50)
    if (resp.code === 0) {
      this.notifications = resp.data || []
    }
    this.loadingNotif = false
  }

  async loadUnreadCount(): Promise<void> {
    const resp = await MessageService.getUnreadCount()
    if (resp.code === 0 && resp.data) {
      this.unreadChat = resp.data.chat || 0
      this.unreadNotif = resp.data.notification || 0
    }
  }

  async markAllNotifRead(): Promise<void> {
    const resp = await MessageService.markAllNotificationsRead()
    if (resp.code === 0) {
      this.unreadNotif = 0
      // 更新列表中所有通知为已读
      const updatedList: Message[] = []
      for (let i = 0; i < this.notifications.length; i++) {
        updatedList.push(this.copyMsgSetRead(this.notifications[i], true))
      }
      this.notifications = updatedList
      promptAction.showToast({ message: '已全部标记为已读' })
    }
  }

  // 搜索用户
  async searchUsers(): Promise<void> {
    if (!this.searchKeyword.trim()) {
      this.searchResults = []
      return
    }
    this.searchingUsers = true
    const resp = await AuthService.searchUsers(this.searchKeyword.trim())
    if (resp.code === 0 && resp.data) {
      // 过滤掉自己
      const filtered: User[] = []
      for (let i = 0; i < resp.data.length; i++) {
        if (Number(resp.data[i].id) !== this.currentUserId) {
          filtered.push(resp.data[i])
        }
      }
      this.searchResults = filtered
    }
    this.searchingUsers = false
  }

  // 手动复制 Message 并修改 isRead（ArkTS 不支持对象展开运算符）
  copyMsgSetRead(src: Message, isRead: boolean): Message {
    return {
      id: src.id,
      conversationId: src.conversationId,
      senderId: src.senderId,
      receiverId: src.receiverId,
      content: src.content,
      messageType: src.messageType,
      notificationType: src.notificationType,
      relatedId: src.relatedId,
      isRead: isRead,
      createdAt: src.createdAt,
      senderName: src.senderName,
      senderAvatar: src.senderAvatar
    }
  }

  getPeerId(msg: Message): number {
    // 从 conversationId 中提取对端用户ID
    const convId = msg.conversationId || ''
    const parts = convId.split('_')
    if (parts.length === 2) {
      return Number(parts[0]) === msg.senderId ? Number(parts[1]) : Number(parts[0])
    }
    return msg.senderId
  }

  build() {
    Column() {
      NavBar({ title: '消息中心', showBack: true })

      // Tab 切换
      Row() {
        this.TabButton('💬', `对话${this.unreadChat > 0 ? ` (${this.unreadChat})` : ''}`, 0)
        this.TabButton('🔔', `通知${this.unreadNotif > 0 ? ` (${this.unreadNotif})` : ''}`, 1)
        if (this.currentTab === 1 && this.unreadNotif > 0) {
          Text('全部已读')
            .fontSize(12)
            .fontColor(Colors.PRIMARY)
            .onClick(() => this.markAllNotifRead())
        }
        if (this.currentTab === 0) {
          Text('➕')
            .fontSize(18)
            .margin({ left: 8 })
            .onClick(() => {
              this.showSearch = !this.showSearch
              this.searchKeyword = ''
              this.searchResults = []
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor(Colors.BG_WHITE)
      .justifyContent(FlexAlign.SpaceBetween)

      // 用户搜索栏
      if (this.currentTab === 0 && this.showSearch) {
        Row() {
          TextInput({ placeholder: '搜索用户昵称或手机号...', text: this.searchKeyword })
            .fontSize(13)
            .layoutWeight(1)
            .height(34)
            .backgroundColor(Colors.BG_PAPER)
            .borderRadius(16)
            .padding({ left: 12, right: 12 })
            .onChange((value: string) => {
              this.searchKeyword = value
              this.searchUsers()
            })

          Text('取消')
            .fontSize(12)
            .fontColor(Colors.TEXT_HINT)
            .margin({ left: 8 })
            .onClick(() => {
              this.showSearch = false
              this.searchResults = []
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .backgroundColor(Colors.BG_WHITE)

        if (this.searchResults.length > 0) {
          Column() {
            ForEach(this.searchResults, (user: User) => {
              Row() {
                if (user.avatar) {
                  Image(user.avatar)
                    .width(36)
                    .height(36)
                    .borderRadius(18)
                    .objectFit(ImageFit.Cover)
                } else {
                  Text((user.nickname || 'U').charAt(0))
                    .fontSize(16)
                    .fontColor(Colors.BG_WHITE)
                    .width(36)
                    .height(36)
                    .borderRadius(18)
                    .backgroundColor(Colors.PRIMARY)
                    .textAlign(TextAlign.Center)
                    .lineHeight(36)
                }
                Column() {
                  Text(user.nickname || '用户')
                    .fontSize(14)
                    .fontColor(Colors.TEXT_PRIMARY)
                  Text(user.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                    .fontSize(11)
                    .fontColor(Colors.TEXT_HINT)
                    .margin({ top: 2 })
                }
                .margin({ left: 10 })
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('发消息 >')
                  .fontSize(12)
                  .fontColor(Colors.PRIMARY)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor(Colors.BG_WHITE)
              .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })
              .onClick(() => {
                this.showSearch = false
                this.searchResults = []
                router.pushUrl({
                  url: Constants.PAGE_CHAT_DETAIL,
                  params: {
                    peerId: Number(user.id),
                    peerName: user.nickname || '用户',
                    currentUserId: this.currentUserId
                  }
                })
              })
            })
          }
          .width('100%')
        } else if (this.searchingUsers) {
          Row() {
            LoadingProgress().width(20).height(20).color(Colors.PRIMARY)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Colors.BG_WHITE)
          .justifyContent(FlexAlign.Center)
        }
      }

      // 内容区
      if (this.currentTab === 0) {
        this.ChatList()
      } else {
        this.NotificationList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PAPER)
  }

  @Builder
  TabButton(icon: string, label: string, index: number) {
    Column() {
      Text(icon + ' ' + label)
        .fontSize(15)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTab === index ? Colors.PRIMARY : Colors.TEXT_SECONDARY)
        .padding({ bottom: 6 })
    }
    .onClick(() => { this.currentTab = index })
    .layoutWeight(1)
    .border({ width: { bottom: this.currentTab === index ? 2 : 0 }, color: Colors.PRIMARY })
  }

  @Builder
  ChatList() {
    if (this.conversations.length === 0 && !this.loadingChat) {
      Column() {
        EmptyState({ message: '暂无对话，去逛逛吧~', iconText: '💬' })
      }
      .width('100%')
      .layoutWeight(1)
    } else {
      Scroll() {
        Column() {
          ForEach(this.conversations, (msg: Message) => {
            Row() {
              // 头像
              if (msg.senderAvatar) {
                Image(msg.senderAvatar)
                  .width(44)
                  .height(44)
                  .borderRadius(22)
                  .objectFit(ImageFit.Cover)
              } else {
                Text((msg.senderName || '?').charAt(0))
                  .fontSize(18)
                  .fontColor(Colors.BG_WHITE)
                  .width(44)
                  .height(44)
                  .borderRadius(22)
                  .backgroundColor(Colors.PRIMARY)
                  .textAlign(TextAlign.Center)
                  .lineHeight(44)
              }

              Column() {
                Text(msg.senderName || '用户')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(msg.content || '')
                  .fontSize(13)
                  .fontColor(Colors.TEXT_HINT)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 4 })
              }
              .margin({ left: 10 })
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column() {
                Text(this.formatTime(msg.createdAt))
                  .fontSize(11)
                  .fontColor(Colors.TEXT_HINT)

                if (!msg.isRead && msg.senderId !== 0) {
                  Row()
                    .width(8)
                    .height(8)
                    .borderRadius(4)
                    .backgroundColor(Colors.PRIMARY)
                    .margin({ top: 6 })
                }
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor(Colors.BG_WHITE)
            .onClick(() => {
              router.pushUrl({
                url: Constants.PAGE_CHAT_DETAIL,
                params: {
                  peerId: this.getPeerId(msg),
                  peerName: msg.senderName || '用户',
                  currentUserId: this.currentUserId
                }
              })
            })
          })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }

    if (this.loadingChat) {
      LoadingProgress().width(28).height(28).color(Colors.PRIMARY).margin({ top: 20 })
    }
  }

  @Builder
  NotificationList() {
    if (this.notifications.length === 0 && !this.loadingNotif) {
      Column() {
        EmptyState({
          message: '暂无通知，维权相关的消息会出现在这里~',
          iconText: '🔔'
        })
      }
      .width('100%')
      .layoutWeight(1)
    } else {
      Scroll() {
        Column() {
          ForEach(this.notifications, (msg: Message) => {
            Row() {
              // 通知图标
              Text(getNotificationIcon(msg.notificationType))
                .fontSize(24)
                .width(40)
                .height(40)
                .borderRadius(10)
                .backgroundColor(Colors.PRIMARY_BG)
                .textAlign(TextAlign.Center)
                .lineHeight(40)

              Column() {
                Row() {
                  Text(getNotificationLabel(msg.notificationType))
                    .fontSize(13)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Colors.PRIMARY)

                  if (!msg.isRead) {
                    Row()
                      .width(6)
                      .height(6)
                      .borderRadius(3)
                      .backgroundColor(Colors.PRIMARY)
                      .margin({ left: 6 })
                  }
                }

                Text(msg.content)
                  .fontSize(14)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 4 })

                Text(this.formatTime(msg.createdAt))
                  .fontSize(11)
                  .fontColor(Colors.TEXT_HINT)
                  .margin({ top: 4 })
              }
              .margin({ left: 10 })
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Image($r('sys.media.ohos_ic_public_arrow_right'))
                .width(14)
                .height(14)
                .fillColor(Colors.TEXT_HINT)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor(Colors.BG_WHITE)
            .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })
            .onClick(async () => {
              // 标记已读
              if (!msg.isRead) {
                await MessageService.markNotificationRead(msg.id)
                this.unreadNotif = Math.max(0, this.unreadNotif - 1)
                // 更新本地状态
                const idx = this.notifications.findIndex((m: Message) => m.id === msg.id)
                if (idx >= 0) {
                  this.notifications[idx] = this.copyMsgSetRead(this.notifications[idx], true)
                  // 触发状态更新（ArkTS 需要新数组引用才能响应变化）
                  const updatedList: Message[] = []
                  for (let i = 0; i < this.notifications.length; i++) {
                    updatedList.push(this.notifications[i])
                  }
                  this.notifications = updatedList
                }
              }
              // 跳转到关联详情
              if (msg.relatedId && msg.notificationType) {
                if (msg.notificationType.startsWith('dispute') || msg.notificationType === 'jury_invite') {
                  router.pushUrl({
                    url: Constants.PAGE_DISPUTE_DETAIL,
                    params: { disputeId: msg.relatedId }
                  })
                } else if (msg.notificationType === 'order_status') {
                  router.pushUrl({
                    url: Constants.PAGE_ORDER_DETAIL,
                    params: { orderId: msg.relatedId }
                  })
                } else if (msg.notificationType === 'artisan_new' || msg.notificationType === 'price_drop') {
                  router.pushUrl({
                    url: Constants.PAGE_PRODUCT_DETAIL,
                    params: { productId: msg.relatedId }
                  })
                }
              }
            })
          })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }

    if (this.loadingNotif) {
      LoadingProgress().width(28).height(28).color(Colors.PRIMARY).margin({ top: 20 })
    }
  }

  formatTime(timeStr: string): string {
    if (!timeStr) return ''
    try {
      const date = new Date(timeStr)
      const now = new Date()
      const diff = now.getTime() - date.getTime()
      if (diff < 60000) return '刚刚'
      if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
      if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
      // 显示月-日 时:分
      const m = String(date.getMonth() + 1).padStart(2, '0')
      const d = String(date.getDate()).padStart(2, '0')
      const h = String(date.getHours()).padStart(2, '0')
      const min = String(date.getMinutes()).padStart(2, '0')
      return `${m}-${d} ${h}:${min}`
    } catch (e) {
      return timeStr
    }
  }
}
