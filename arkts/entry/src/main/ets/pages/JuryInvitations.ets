// 陪审邀请列表页 — 收到陪审邀请并投票
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { DisputeService } from '../service/DisputeService'
import { JuryInvitation } from '../model/Dispute'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct JuryInvitations {
  @State invitations: JuryInvitation[] = []
  @State loading: boolean = true
  @State votingId: string = ''
  @State showVoteModal: boolean = false
  @State currentDisputeId: string = ''

  aboutToAppear(): void {
    this.loadList()
  }

  async loadList(): Promise<void> {
    this.loading = true
    const resp = await DisputeService.getMyInvitations()
    if (resp.code === 0) {
      this.invitations = resp.data
    }
    this.loading = false
  }

  async handleVote(disputeId: string, side: string): Promise<void> {
    this.votingId = disputeId
    const resp = await DisputeService.vote(disputeId, side)
    this.votingId = ''
    this.showVoteModal = false
    if (resp.code === 0) {
      promptAction.showToast({ message: '投票成功' })
      this.loadList()
    } else {
      promptAction.showToast({ message: resp.message || '投票失败' })
    }
  }

  showVote(disputeId: string): void {
    this.currentDisputeId = disputeId
    this.showVoteModal = true
  }

  build() {
    Stack() {
      Column() {
        NavBar({ title: '陪审邀请', showBack: true })

        if (this.loading) {
          Row() {
            LoadingProgress().width(24).height(24).color(Colors.PRIMARY)
          }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        } else if (this.invitations.length === 0) {
          EmptyState({ message: '暂无陪审邀请', iconText: '👨‍⚖️' })
        } else {
          Scroll() {
            Column() {
              ForEach(this.invitations, (inv: JuryInvitation) => {
                Column() {
                  Row() {
                    Text('⚖️').fontSize(28).margin({ right: 12 })
                    Column() {
                      Text(`纠纷 #${inv.disputeId}`)
                        .fontSize(14).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)
                      Text(inv.disputeReason || '')
                        .fontSize(12).fontColor(Colors.TEXT_SECONDARY)
                        .maxLines(2).margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start).layoutWeight(1)

                    Text(inv.status === 'voted' ? '已投票' : '待投票')
                      .fontSize(11)
                      .fontColor(inv.status === 'voted' ? '#1E8449' : '#856404')
                      .backgroundColor(inv.status === 'voted' ? '#D5F5E3' : '#FFF3CD')
                      .borderRadius(4)
                      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  }
                  .width('100%')

                  if (inv.status === 'pending') {
                    Button('参与投票')
                      .fontSize(13)
                      .backgroundColor(Colors.PRIMARY)
                      .borderRadius(18).height(32).width('100%')
                      .margin({ top: 12 })
                      .onClick(() => { this.showVote(inv.disputeId) })
                  } else if (inv.voteTime) {
                    Text(`投票时间: ${inv.voteTime}`)
                      .fontSize(11).fontColor(Colors.TEXT_HINT).margin({ top: 8 })
                  }
                }
                .width('100%')
                .padding(14)
                .backgroundColor(Colors.BG_WHITE)
                .borderRadius(8)
                .margin({ top: 8 })
              })
            }
            .padding({ left: 16, right: 16 })
          }
          .width('100%').layoutWeight(1).backgroundColor(Colors.BG_PAPER).scrollBar(BarState.Off)
        }
      }
      .width('100%').height('100%')

      // 投票弹窗
      if (this.showVoteModal) {
        Column() {
          Column()
            .width('100%').height('100%')
            .backgroundColor('#4D000000')
            .onClick(() => { this.showVoteModal = false })

          Column() {
            Text('选择投票方')
              .fontSize(16).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)
              .margin({ top: 24, bottom: 20 })

            Row() {
              Button('支持买家')
                .fontSize(15).backgroundColor('#922B21').borderRadius(22).height(44).layoutWeight(1)
                .onClick(() => this.handleVote(this.currentDisputeId, 'buyer'))
                .margin({ right: 8 })
              Button('支持卖家')
                .fontSize(15).backgroundColor('#1A5276').borderRadius(22).height(44).layoutWeight(1)
                .onClick(() => this.handleVote(this.currentDisputeId, 'seller'))
                .margin({ left: 8 })
            }
            .width('100%').margin({ bottom: 8 })

            Button('取消')
              .fontSize(14).backgroundColor(Colors.BG_PAPER).fontColor(Colors.TEXT_SECONDARY)
              .borderRadius(22).height(40).width('100%')
              .onClick(() => { this.showVoteModal = false })
              .margin({ bottom: 24 })
          }
          .width('84%')
          .padding({ left: 20, right: 20 })
          .backgroundColor(Colors.BG_WHITE)
          .borderRadius(16)
          .position({ x: '8%', y: '30%' })
        }
      }
    }
    .width('100%').height('100%')
  }
}
