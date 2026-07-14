// 聊天详情页 — 与某用户的私信对话
import { router, promptAction, KeyboardAvoidMode } from '@kit.ArkUI'
import { Constants } from '../common/Constants'
import { NavBar } from '../components/NavBar'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'
import { MessageService, ChatMessage } from '../service/MessageService'

@Entry
@Component
struct ChatDetail {
  @State messages: ChatMessage[] = []
  @State inputText: string = ''
  @State sending: boolean = false
  private otherId: string = ''
  private otherName: string = ''

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  aboutToAppear(): void {
    // 键盘弹出时收缩页面（列表变短）而非整体上移，避免顶部被顶掉
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
    const params = router.getParams() as Record<string, string>
    if (params) {
      this.otherId = params['otherId'] ?? ''
      this.otherName = params['otherName'] ?? this.t('聊天', 'Chat')
    }
    this.loadChat()
  }

  aboutToDisappear(): void {
    // 恢复默认，避免影响其它页面
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
  }

  async loadChat(): Promise<void> {
    if (!this.otherId) return
    const resp = await MessageService.fetchChat(this.otherId)
    if (resp.code === 0) {
      this.messages = resp.data
    }
  }

  async sendMessage(): Promise<void> {
    const text = this.inputText.trim()
    if (!text || this.sending) return
    this.sending = true
    const resp = await MessageService.send(this.otherId, text)
    this.sending = false
    if (resp.code === 0) {
      this.inputText = ''
      this.loadChat()
    } else {
      promptAction.showToast({ message: resp.message || this.t('发送失败', 'Failed') })
    }
  }

  build() {
    Column() {
      NavBar({
        title: this.otherName,
        showBack: true,
        onTitleClick: () => {
          if (this.otherId) {
            router.pushUrl({ url: Constants.PAGE_USER_PROFILE, params: { userId: this.otherId } })
          }
        }
      })

      // 消息列表
      if (this.messages.length === 0) {
        Column() {
          Text(this.t('打个招呼，开始聊天吧', 'Say hi to start chatting'))
            .fontSize(this.fs(13)).fontColor(Theme.textHint(this.theme))
        }
        .layoutWeight(1).width('100%').justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.messages, (m: ChatMessage) => {
            ListItem() {
              Row() {
                if (m.fromMe) {
                  Blank()
                  Text(m.content)
                    .fontSize(this.fs(14)).fontColor(Theme.WHITE)
                    .backgroundColor(Theme.primary(this.theme))
                    .borderRadius(10).padding(10).constraintSize({ maxWidth: '70%' })
                } else {
                  Text(m.content)
                    .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
                    .backgroundColor(Theme.card(this.theme))
                    .borderRadius(10).padding(10).constraintSize({ maxWidth: '70%' })
                  Blank()
                }
              }
              .width('100%')
            }
          })
        }
        .layoutWeight(1).width('100%').padding({ left: 12, right: 12, top: 12 })
        .scrollBar(BarState.Off)
      }

      // 输入区
      Row() {
        TextInput({ placeholder: this.t('发消息…', 'Message...'), text: this.inputText })
          .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
          .placeholderColor(Theme.textHint(this.theme))
          .backgroundColor(Theme.bg(this.theme))
          .borderRadius(18).height(38).layoutWeight(1)
          .onChange((v: string) => { this.inputText = v })

        Button(this.t('发送', 'Send'))
          .fontSize(this.fs(14)).fontColor(Theme.WHITE)
          .backgroundColor(this.inputText.trim() ? Theme.primary(this.theme) : Theme.textHint(this.theme))
          .borderRadius(18).height(38).margin({ left: 8 })
          .enabled(!!this.inputText.trim() && !this.sending)
          .onClick(() => { this.sendMessage() })
      }
      .width('100%').padding({ left: 12, right: 12, top: 8, bottom: 12 })
      .backgroundColor(Theme.card(this.theme))
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }
}
