// 纠纷详情页
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { DisputeService } from '../service/DisputeService'
import { Dispute, VoteStats, getDisputeStatusText, getDisputeResultText } from '../model/Dispute'
import { NavBar } from '../components/NavBar'

@Entry
@Component
struct DisputeDetail {
  @State dispute: Dispute | undefined = undefined
  @State stats: VoteStats | undefined = undefined
  @State loading: boolean = true
  @State requestingJury: boolean = false
  private disputeId: string = ''

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
      promptAction.showToast({ message: '已申请陪审团' })
      this.loadDetail()
    } else {
      promptAction.showToast({ message: resp.message || '操作失败' })
    }
  }

  build() {
    Column() {
      NavBar({ title: '维权详情', showBack: true })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Colors.PRIMARY)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (!this.dispute) {
        Column() {
          Text('纠纷不存在').fontSize(14).fontColor(Colors.TEXT_HINT)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 状态卡
            Column() {
              Text(getDisputeStatusText(this.dispute!.status))
                .fontSize(24).fontWeight(FontWeight.Bold)
                .fontColor(this.dispute!.status === 'negotiating' ? '#856404' :
                  this.dispute!.status === 'voting' ? '#1A5276' : '#1E8449')
              if (this.dispute!.result) {
                Text(getDisputeResultText(this.dispute!.result))
                  .fontSize(16)
                  .fontColor(this.dispute!.result === 'buyer_win' ? '#922B21' : '#1A5276')
                  .margin({ top: 4 })
              }
            }
            .width('100%').padding(24)
            .backgroundColor(this.dispute!.status === 'negotiating' ? '#FFF3CD' :
              this.dispute!.status === 'voting' ? '#D6EAF8' : '#D5F5E3')

            // 纠纷信息
            Column() {
              this.InfoRow('订单编号', this.dispute!.orderNo)
              this.InfoRow('商品名称', this.dispute!.productName)
              this.InfoRow('申请人', this.dispute!.initiatorName || '')
              this.InfoRow('被申请人', this.dispute!.respondentName || '')
              this.InfoRow('创建时间', this.dispute!.createdAt || '')
            }
            .width('100%').padding(16).backgroundColor(Colors.BG_WHITE).margin({ top: 8 })

            // 维权原因
            Column() {
              Text('维权原因')
                .fontSize(14).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)
              Text(this.dispute!.reason || '')
                .fontSize(13).fontColor(Colors.TEXT_SECONDARY).margin({ top: 8 })
            }
            .width('100%').padding(16).backgroundColor(Colors.BG_WHITE).margin({ top: 8 })

            // 投票统计 (voting/resolved)
            if (this.stats) {
              Column() {
                Text('陪审投票').fontSize(14).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)

                Row() {
                  Text(`买家方: ${this.stats!.buyerVotes} 票`)
                    .fontSize(13).fontColor('#922B21').layoutWeight(1)
                  Text(`卖家方: ${this.stats!.sellerVotes} 票`)
                    .fontSize(13).fontColor('#1A5276').layoutWeight(1)
                  Text(`共 ${this.stats!.totalVotes} 票`)
                    .fontSize(13).fontColor(Colors.TEXT_SECONDARY).layoutWeight(1)
                }
                .width('100%').margin({ top: 12 })

                Text(`买家支持率: ${(this.stats!.buyerRate).toFixed(1)}%`)
                  .fontSize(12).fontColor(Colors.TEXT_HINT).margin({ top: 8 })
              }
              .width('100%').padding(16).backgroundColor(Colors.BG_WHITE).margin({ top: 8 })
            }

            Row().height(80)
          }
        }
        .width('100%').layoutWeight(1).backgroundColor(Colors.BG_PAPER).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%')

    // 底部操作: 申请陪审团
    if (this.dispute && this.dispute.status === 'negotiating') {
      Row() {
        Button(this.requestingJury ? '申请中...' : '申请陪审团介入')
          .fontSize(15)
          .backgroundColor(this.requestingJury ? Colors.TEXT_HINT : Colors.PRIMARY)
          .borderRadius(22).height(44).layoutWeight(1)
          .onClick(() => { if (!this.requestingJury) this.handleRequestJury() })
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Colors.BG_WHITE)
    }
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(12).fontColor(Colors.TEXT_SECONDARY).width(72)
      Text(value).fontSize(12).fontColor(Colors.TEXT_PRIMARY).layoutWeight(1)
    }
    .width('100%').margin({ top: 8 })
  }
}
