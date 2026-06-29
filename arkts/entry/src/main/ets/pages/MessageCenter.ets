// 消息中心 — 系统通知 + 私信会话 两个 Tab
import { router } from '@kit.ArkUI'
import { Constants } from '../common/Constants'
import { NavBar } from '../components/NavBar'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'
import { NotificationService, NotificationItem } from '../service/NotificationService'
import { MessageService, Conversation } from '../service/MessageService'

@Entry
@Component
struct MessageCenter {
  @State activeTab: number = 0
  @State notifications: NotificationItem[] = []
  @State conversations: Conversation[] = []
  @State loading: boolean = true

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  onPageShow(): void {
    this.loadAll()
  }

  async loadAll(): Promise<void> {
    this.loading = true
    const nResp = await NotificationService.fetchList()
    if (nResp.code === 0) this.notifications = nResp.data
    const cResp = await MessageService.fetchConversations()
    if (cResp.code === 0) this.conversations = cResp.data
    this.loading = false
  }

  async markAllRead(): Promise<void> {
    await NotificationService.markAllRead()
    this.loadAll()
  }

  build() {
    Column() {
      NavBar({ title: this.t('消息', 'Messages'), showBack: true })

      // Tab 头
      Row() {
        this.TabItem(this.t('通知', 'Notifications'), 0)
        this.TabItem(this.t('私信', 'Chats'), 1)
      }
      .width('100%')
      .height(44)
      .backgroundColor(Theme.card(this.theme))

      if (this.activeTab === 0) {
        this.NotificationList()
      } else {
        this.ConversationList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }

  @Builder
  TabItem(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(this.fs(15))
        .fontWeight(this.activeTab === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.activeTab === index ? Theme.primary(this.theme) : Theme.textSecondary(this.theme))
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .border(this.activeTab === index ? { width: { bottom: 2 }, color: Theme.primary(this.theme) } : { width: 0 })
    .onClick(() => { this.activeTab = index })
  }

  @Builder
  NotificationList() {
    if (this.notifications.length === 0) {
      this.EmptyTip('🔔', this.t('暂无通知', 'No notifications'))
    } else {
      Column() {
        Row() {
          Blank()
          Text(this.t('全部已读', 'Mark all read'))
            .fontSize(this.fs(12))
            .fontColor(Theme.primary(this.theme))
            .onClick(() => { this.markAllRead() })
        }
        .width('100%').padding({ left: 16, right: 16, top: 8, bottom: 4 })

        List() {
          ForEach(this.notifications, (n: NotificationItem) => {
            ListItem() {
              Row() {
                // 未读红点
                Circle({ width: 8, height: 8 })
                  .fill(n.isRead ? Color.Transparent : Theme.primary(this.theme))
                  .margin({ right: 8, top: 6 })

                Column() {
                  Row() {
                    Text(n.title)
                      .fontSize(this.fs(14)).fontWeight(FontWeight.Medium)
                      .fontColor(Theme.textPrimary(this.theme))
                    Blank()
                    Text(n.time).fontSize(this.fs(11)).fontColor(Theme.textHint(this.theme))
                  }
                  .width('100%')
                  Text(n.content)
                    .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme))
                    .margin({ top: 4 }).width('100%')
                    .maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1).alignItems(HorizontalAlign.Start)
              }
              .width('100%').padding(14).alignItems(VerticalAlign.Top)
              .backgroundColor(Theme.card(this.theme))
              .onClick(() => {
                if (!n.isRead) {
                  NotificationService.markRead(n.id).then(() => { this.loadAll() })
                }
              })
            }
          })
        }
        .layoutWeight(1).width('100%').divider({ strokeWidth: 0.5, color: Theme.divider(this.theme) })
      }
      .layoutWeight(1).width('100%')
    }
  }

  @Builder
  ConversationList() {
    if (this.conversations.length === 0) {
      this.EmptyTip('💬', this.t('暂无私信', 'No chats'))
    } else {
      List() {
        ForEach(this.conversations, (c: Conversation) => {
          ListItem() {
            Row() {
              Image(c.otherAvatar || 'https://picsum.photos/seed/chat/48/48')
                .width(44).height(44).borderRadius(22).objectFit(ImageFit.Cover)

              Column() {
                Row() {
                  Text(c.otherName).fontSize(this.fs(15)).fontWeight(FontWeight.Medium)
                    .fontColor(Theme.textPrimary(this.theme))
                  Blank()
                  Text(c.time).fontSize(this.fs(11)).fontColor(Theme.textHint(this.theme))
                }
                .width('100%')
                Text(c.lastContent)
                  .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme))
                  .margin({ top: 4 }).width('100%').maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)

              if (c.unread > 0) {
                Text(`${c.unread}`)
                  .fontSize(this.fs(11)).fontColor(Theme.WHITE)
                  .backgroundColor(Theme.primary(this.theme))
                  .borderRadius(9).constraintSize({ minWidth: 18 }).height(18)
                  .textAlign(TextAlign.Center).padding({ left: 5, right: 5})
                  .margin({ left: 6 })
              }
            }
            .width('100%').padding(14).backgroundColor(Theme.card(this.theme))
            .onClick(() => {
              const p: Record<string, string> = {}
              p['otherId'] = c.otherId
              p['otherName'] = c.otherName
              router.pushUrl({ url: Constants.PAGE_CHAT_DETAIL, params: p })
            })
          }
        })
      }
      .layoutWeight(1).width('100%').divider({ strokeWidth: 0.5, color: Theme.divider(this.theme) })
    }
  }

  @Builder
  EmptyTip(icon: string, text: string) {
    Column() {
      Text(icon).fontSize(this.fs(48)).opacity(0.6)
      Text(text).fontSize(this.fs(14)).fontColor(Theme.textHint(this.theme)).margin({ top: 8 })
    }
    .layoutWeight(1).width('100%').justifyContent(FlexAlign.Center)
  }
}
