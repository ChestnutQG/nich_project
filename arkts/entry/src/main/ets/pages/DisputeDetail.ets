// 纠纷详情页
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { DisputeService } from '../service/DisputeService'
import { Dispute, VoteStats, getDisputeStatusText, getDisputeResultText } from '../model/Dispute'
import { NavBar } from '../components/NavBar'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct DisputeDetail {
  @State dispute: Dispute | undefined = undefined
  @State stats: VoteStats | undefined = undefined
  @State loading: boolean = true
  @State requestingJury: boolean = false
  private disputeId: string = ''

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
    const params = router.getParams() as Record<string, string>
    if (params && params['disputeId']) {
      this.disputeId = params['disputeId']
      this.loadDetail()
    }
  }

  async loadDetail(): Promise<void> {
    this.loading = true
    const resp = await DisputeService.getDetail(this.disputeId)
    if (resp.code === 0 && resp.data) {
      this.dispute = resp.data
      if (this.dispute!.status === 'voting' || this.dispute!.status === 'resolved') {
        this.loadStats()
      }
    }
    this.loading = false
  }

  async loadStats(): Promise<void> {
    const resp = await DisputeService.getVoteStats(this.disputeId)
    if (resp.code === 0) {
      this.stats = resp.data
    }
  }

  async handleRequestJury(): Promise<void> {
    this.requestingJury = true
    const resp = await DisputeService.requestJury(this.disputeId)
    this.requestingJury = false
    if (resp.code === 0) {
      promptAction.showToast({ message: this.t('已申请陪审团', 'Jury requested') })
      this.loadDetail()
    } else {
      promptAction.showToast({ message: resp.message || this.t('操作失败', 'Failed') })
    }
  }

  build() {
    Column() {
      Column() {
        NavBar({ title: this.t('维权详情', 'Dispute Detail'), showBack: true })

        if (this.loading) {
          Row() {
            LoadingProgress().width(24).height(24).color(Theme.primary(this.theme))
          }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.bg(this.theme))
        } else if (!this.dispute) {
          Column() {
            Text(this.t('纠纷不存在', 'Dispute not found'))
              .fontSize(this.fs(14)).fontColor(Theme.textHint(this.theme))
          }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.bg(this.theme))
        } else {
          Scroll() {
            Column() {
              // 状态卡
              Column() {
                Text(getDisputeStatusText(this.dispute!.status))
                  .fontSize(this.fs(24)).fontWeight(FontWeight.Bold)
                  .fontColor(this.dispute!.status === 'negotiating' ? '#856404' :
                    this.dispute!.status === 'voting' ? '#1A5276' : '#1E8449')
                if (this.dispute!.result) {
                  Text(getDisputeResultText(this.dispute!.result))
                    .fontSize(this.fs(16))
                    .fontColor(this.dispute!.result === 'buyer_win' ? '#922B21' : '#1A5276')
                    .margin({ top: 4 })
                }
              }
              .width('100%').padding(24)
              .backgroundColor(this.dispute!.status === 'negotiating' ? '#FFF3CD' :
                this.dispute!.status === 'voting' ? '#D6EAF8' : '#D5F5E3')

              // 纠纷信息
              Column() {
                this.InfoRow(this.t('订单编号', 'Order No.'), this.dispute!.orderNo)
                this.InfoRow(this.t('商品名称', 'Product'), this.dispute!.productName)
                this.InfoRow(this.t('申请人', 'Initiator'), this.dispute!.initiatorName || '')
                this.InfoRow(this.t('被申请人', 'Respondent'), this.dispute!.respondentName || '')
                this.InfoRow(this.t('创建时间', 'Created'), this.dispute!.createdAt || '')
              }
              .width('100%').padding(16).backgroundColor(Theme.card(this.theme)).margin({ top: 8 })

              // 维权原因
              Column() {
                Text(this.t('维权原因', 'Reason'))
                  .fontSize(this.fs(14)).fontWeight(FontWeight.Medium).fontColor(Theme.textPrimary(this.theme))
                Text(this.dispute!.reason || '')
                  .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme)).margin({ top: 8 })
              }
              .width('100%').padding(16).backgroundColor(Theme.card(this.theme)).margin({ top: 8 })

              // 投票统计 (voting/resolved)
              if (this.stats) {
                Column() {
                  Text(this.t('陪审投票', 'Jury Votes'))
                    .fontSize(this.fs(14)).fontWeight(FontWeight.Medium).fontColor(Theme.textPrimary(this.theme))

                  Row() {
                    Text(`${this.t('买家方', 'Buyer')}: ${this.stats!.buyerVotes} ${this.t('票', '')}`)
                      .fontSize(this.fs(13)).fontColor('#922B21').layoutWeight(1)
                    Text(`${this.t('卖家方', 'Seller')}: ${this.stats!.sellerVotes} ${this.t('票', '')}`)
                      .fontSize(this.fs(13)).fontColor('#1A5276').layoutWeight(1)
                    Text(`${this.t('共', 'Total')} ${this.stats!.totalVotes} ${this.t('票', '')}`)
                      .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme)).layoutWeight(1)
                  }
                  .width('100%').margin({ top: 12 })

                  Text(`${this.t('买家支持率', 'Buyer rate')}: ${(this.stats!.buyerRate).toFixed(1)}%`)
                    .fontSize(this.fs(12)).fontColor(Theme.textHint(this.theme)).margin({ top: 8 })
                }
                .width('100%').padding(16).backgroundColor(Theme.card(this.theme)).margin({ top: 8 })
              }

              Row().height(80)
            }
          }
          .width('100%').layoutWeight(1).backgroundColor(Theme.bg(this.theme)).scrollBar(BarState.Off)
        }
      }
      .width('100%').layoutWeight(1)

      // 底部操作: 申请陪审团
      if (this.dispute && this.dispute.status === 'negotiating') {
        Row() {
          Button(this.requestingJury ? this.t('申请中...', 'Requesting...') : this.t('申请陪审团介入', 'Request Jury'))
            .fontSize(this.fs(15))
            .backgroundColor(this.requestingJury ? Theme.textHint(this.theme) : Theme.primary(this.theme))
            .borderRadius(22).height(44).layoutWeight(1)
            .onClick(() => { if (!this.requestingJury) this.handleRequestJury() })
        }
        .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor(Theme.card(this.theme))
      }
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(this.fs(12)).fontColor(Theme.textSecondary(this.theme)).width(72)
      Text(value).fontSize(this.fs(12)).fontColor(Theme.textPrimary(this.theme)).layoutWeight(1)
    }
    .width('100%').margin({ top: 8 })
  }
}
