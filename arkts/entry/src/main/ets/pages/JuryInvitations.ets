// 陪审邀请列表页 — 收到陪审邀请并投票
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { DisputeService } from '../service/DisputeService'
import { JuryInvitation } from '../model/Dispute'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct JuryInvitations {
  @State invitations: JuryInvitation[] = []
  @State loading: boolean = true
  @State votingId: string = ''
  @State showVoteModal: boolean = false
  @State currentDisputeId: string = ''

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
      promptAction.showToast({ message: this.t('投票成功', 'Vote submitted') })
      this.loadList()
    } else {
      promptAction.showToast({ message: resp.message || this.t('投票失败', 'Vote failed') })
    }
  }

  showVote(disputeId: string): void {
    this.currentDisputeId = disputeId
    this.showVoteModal = true
  }

  build() {
    Stack() {
      Column() {
        NavBar({ title: this.t('陪审邀请', 'Jury Invitations'), showBack: true })

        if (this.loading) {
          Row() {
            LoadingProgress().width(24).height(24).color(Theme.primary(this.theme))
          }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.bg(this.theme))
        } else if (this.invitations.length === 0) {
          EmptyState({ message: this.t('暂无陪审邀请', 'No invitations'), iconText: '👨‍⚖️' })
        } else {
          Scroll() {
            Column() {
              ForEach(this.invitations, (inv: JuryInvitation) => {
                Column() {
                  Row() {
                    Text('⚖️').fontSize(this.fs(28)).margin({ right: 12 })
                    Column() {
                      Text(`${this.t('纠纷', 'Dispute')} #${inv.disputeId}`)
                        .fontSize(this.fs(14)).fontWeight(FontWeight.Medium).fontColor(Theme.textPrimary(this.theme))
                      Text(inv.disputeReason || '')
                        .fontSize(this.fs(12)).fontColor(Theme.textSecondary(this.theme))
                        .maxLines(2).margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start).layoutWeight(1)

                    Text(inv.status === 'voted' ? this.t('已投票', 'Voted') : this.t('待投票', 'Pending'))
                      .fontSize(this.fs(11))
                      .fontColor(inv.status === 'voted' ? '#1E8449' : '#856404')
                      .backgroundColor(inv.status === 'voted' ? '#D5F5E3' : '#FFF3CD')
                      .borderRadius(4)
                      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  }
                  .width('100%')

                  if (inv.status === 'pending') {
                    Button(this.t('参与投票', 'Vote Now'))
                      .fontSize(this.fs(13))
                      .backgroundColor(Theme.primary(this.theme))
                      .borderRadius(18).height(32).width('100%')
                      .margin({ top: 12 })
                      .onClick(() => { this.showVote(inv.disputeId) })
                  } else if (inv.voteTime) {
                    Text(`${this.t('投票时间', 'Voted at')}: ${inv.voteTime}`)
                      .fontSize(this.fs(11)).fontColor(Theme.textHint(this.theme)).margin({ top: 8 })
                  }
                }
                .width('100%')
                .padding(14)
                .backgroundColor(Theme.card(this.theme))
                .borderRadius(8)
                .margin({ top: 8 })
              })
            }
            .padding({ left: 16, right: 16 })
          }
          .width('100%').layoutWeight(1).backgroundColor(Theme.bg(this.theme)).scrollBar(BarState.Off)
        }
      }
      .width('100%').height('100%')
      .backgroundColor(Theme.bg(this.theme))

      // 投票弹窗
      if (this.showVoteModal) {
        Column() {
          Column()
            .width('100%').height('100%')
            .backgroundColor('#4D000000')
            .onClick(() => { this.showVoteModal = false })

          Column() {
            Text(this.t('选择投票方', 'Choose Your Side'))
              .fontSize(this.fs(16)).fontWeight(FontWeight.Medium).fontColor(Theme.textPrimary(this.theme))
              .margin({ top: 24, bottom: 20 })

            Row() {
              Button(this.t('支持买家', 'Support Buyer'))
                .fontSize(this.fs(15)).backgroundColor('#922B21').borderRadius(22).height(44).layoutWeight(1)
                .onClick(() => this.handleVote(this.currentDisputeId, 'buyer'))
                .margin({ right: 8 })
              Button(this.t('支持卖家', 'Support Seller'))
                .fontSize(this.fs(15)).backgroundColor('#1A5276').borderRadius(22).height(44).layoutWeight(1)
                .onClick(() => this.handleVote(this.currentDisputeId, 'seller'))
                .margin({ left: 8 })
            }
            .width('100%').margin({ bottom: 8 })

            Button(this.t('取消', 'Cancel'))
              .fontSize(this.fs(14)).backgroundColor(Theme.bg(this.theme)).fontColor(Theme.textSecondary(this.theme))
              .borderRadius(22).height(40).width('100%')
              .onClick(() => { this.showVoteModal = false })
              .margin({ bottom: 24 })
          }
          .width('84%')
          .padding({ left: 20, right: 20 })
          .backgroundColor(Theme.card(this.theme))
          .borderRadius(16)
          .position({ x: '8%', y: '30%' })
        }
      }
    }
    .width('100%').height('100%')
  }
}
