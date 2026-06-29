// 聊天详情页 — 实时对话
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Message } from '../model/Message'
import { MessageService } from '../service/MessageService'
import { WebSocketManager, WsMessage } from '../service/WebSocketManager'
import { NavBar } from '../components/NavBar'

@Entry
@Component
struct ChatDetail {
  @State messages: Message[] = []
  @State inputText: string = ''
  @State loading: boolean = true
  @State peerId: number = 0
  @State peerName: string = '聊天'
  @State currentUserId: number = 0
  private wsManager: WebSocketManager = new WebSocketManager()
  private scrollController: Scroller = new Scroller()

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      this.peerId = Number(params['peerId']) || 0
      this.peerName = (params['peerName'] as string) || '聊天'
      this.currentUserId = Number(params['currentUserId']) || 0
    }
    this.loadMessages()
    this.connectWs()
  }

  aboutToDisappear(): void {
    this.wsManager.close()
  }

  async loadMessages(): Promise<void> {
    this.loading = true
    const resp = await MessageService.getChatMessages(this.peerId)
    if (resp.code === 0 && resp.data) {
      this.messages = resp.data
      setTimeout(() => {
        this.scrollController.scrollEdge(Edge.Bottom)
      }, 300)
    }
    this.loading = false
    await MessageService.markConversationRead(this.peerId)
  }

  connectWs(): void {
    this.wsManager.onMessage((msg: WsMessage) => {
      if (msg.type === 'chat') {
        if ((msg.senderId === this.peerId && msg.receiverId === this.currentUserId) ||
          (msg.senderId === this.currentUserId && msg.receiverId === this.peerId)) {
          if (msg.senderId === this.currentUserId && msg.id && msg.id > 0) {
            this.replaceTemp(msg)
          } else if (msg.senderId === this.peerId) {
            const m: Message = {
              id: msg.id || 0,
              conversationId: '',
              senderId: msg.senderId || 0,
              receiverId: msg.receiverId || 0,
              content: msg.content || '',
              messageType: 'chat',
              isRead: false,
              createdAt: msg.createdAt || ''
            }
            this.messages = this.addMsg(this.messages, m)
            setTimeout(() => { this.scrollController.scrollEdge(Edge.Bottom) }, 150)
            MessageService.markConversationRead(this.peerId)
          }
        }
      } else if (msg.type === 'notification') {
        promptAction.showToast({ message: msg.content || '新通知', duration: 2000 })
      }
    })
    this.wsManager.connect()
  }

  replaceTemp(confirmed: WsMessage): void {
    const arr: Message[] = []
    let done = false
    for (let i = 0; i < this.messages.length; i++) {
      const m = this.messages[i]
      if (!done && m.senderId === this.currentUserId &&
        m.id > 1000000000000 && m.content === confirmed.content) {
        arr.push({
          id: confirmed.id || 0,
          conversationId: '',
          senderId: confirmed.senderId || 0,
          receiverId: confirmed.receiverId || 0,
          content: confirmed.content || '',
          messageType: 'chat',
          isRead: true,
          createdAt: confirmed.createdAt || ''
        })
        done = true
      } else {
        arr.push(m)
      }
    }
    if (!done && confirmed.content) {
      arr.push({
        id: confirmed.id || 0,
        conversationId: '',
        senderId: confirmed.senderId || 0,
        receiverId: confirmed.receiverId || 0,
        content: confirmed.content || '',
        messageType: 'chat',
        isRead: true,
        createdAt: confirmed.createdAt || ''
      })
    }
    this.messages = arr
  }

  addMsg(list: Message[], item: Message): Message[] {
    const r: Message[] = []
    for (let i = 0; i < list.length; i++) { r.push(list[i]) }
    r.push(item)
    return r
  }

  async sendMessage(): Promise<void> {
    const text = this.inputText.trim()
    if (!text) { return }
    this.inputText = ''
    const tmp: Message = {
      id: new Date().getTime(),
      conversationId: '',
      senderId: this.currentUserId,
      receiverId: this.peerId,
      content: text,
      messageType: 'chat',
      isRead: true,
      createdAt: ''
    }
    this.messages = this.addMsg(this.messages, tmp)
    setTimeout(() => { this.scrollController.scrollEdge(Edge.Bottom) }, 100)
    this.wsManager.sendChat(this.peerId, text)
  }

  build() {
    Column() {
      NavBar({ title: this.peerName, showBack: true })

      if (this.loading) {
        Column() {
          LoadingProgress().width(28).height(28).color(Colors.PRIMARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.messages.length === 0) {
        Column() {
          Text('💬').fontSize(48).opacity(0.4)
          Text('发送第一条消息吧~').fontSize(14).fontColor(Colors.TEXT_HINT).margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll(this.scrollController) {
          Column() {
            ForEach(this.messages, (msg: Message, idx: number) => {
              this.MessageBubble(msg)
            }, (msg: Message) => msg.id.toString())
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

      // 输入栏
      Row() {
        TextInput({ placeholder: '输入消息...' })
          .fontSize(14)
          .placeholderColor(Colors.TEXT_HINT)
          .backgroundColor(Colors.BG_PAPER)
          .borderRadius(20)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .layoutWeight(1)
          .height(38)
          .onChange((value: string) => { this.inputText = value })
          .onSubmit(() => { this.sendMessage() })

        Text('发送')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.inputText.trim().length > 0 ? Colors.PRIMARY : Colors.TEXT_HINT)
          .padding({ left: 14, right: 4 })
          .onClick(() => { this.sendMessage() })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor(Color.White)
      .border({ width: { top: 0.5 }, color: Colors.DIVIDER })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PAPER)
  }

  @Builder
  MessageBubble(msg: Message) {
    Column() {
      if (msg.senderId === this.currentUserId) {
        // 我发的 — 右对齐
        Row() {
          Blank()
          Column() {
            Text(msg.content)
              .fontSize(15)
              .fontColor(Color.White)
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .borderRadius(16)
              .backgroundColor(Colors.PRIMARY)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.End)

        Text(this.fmtTime(msg.createdAt))
          .fontSize(10)
          .fontColor(Colors.TEXT_HINT)
          .textAlign(TextAlign.End)
          .width('100%')
          .padding({ right: 4, top: 4 })
      } else {
        // 对方发的 — 左对齐
        Row() {
          Column() {
            Text(msg.content)
              .fontSize(15)
              .fontColor(Colors.TEXT_PRIMARY)
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .borderRadius(16)
              .backgroundColor(Color.White)
              .border({ width: 0.5, color: Colors.DIVIDER })
          }
          Blank()
        }
        .width('100%')

        Text(this.fmtTime(msg.createdAt))
          .fontSize(10)
          .fontColor(Colors.TEXT_HINT)
          .textAlign(TextAlign.Start)
          .width('100%')
          .padding({ left: 4, top: 4 })
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
  }

  fmtTime(s: string): string {
    if (!s) { return '' }
    try {
      const d = new Date(s)
      const h = String(d.getHours()).padStart(2, '0')
      const m = String(d.getMinutes()).padStart(2, '0')
      return h + ':' + m
    } catch (e) {
      return ''
    }
  }
}
