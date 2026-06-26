// 纠纷列表页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { DisputeService } from '../service/DisputeService'
import { Dispute, getDisputeStatusText, getDisputeResultText } from '../model/Dispute'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct DisputeList {
  @State disputes: Dispute[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    this.loadList()
  }

  async loadList(): Promise<void> {
    this.loading = true
    const resp = await DisputeService.getMyDisputes()
    if (resp.code === 0) {
      this.disputes = resp.data
    }
    this.loading = false
  }

  build() {
    Column() {
      NavBar({ title: '我的维权', showBack: true })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Colors.PRIMARY)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.disputes.length === 0) {
        EmptyState({ message: '暂无维权记录', iconText: '⚖️' })
      } else {
        Scroll() {
          Column() {
            ForEach(this.disputes, (d: Dispute) => {
              Column() {
                Row() {
                  Column() {
                    Text(d.orderNo || '')
                      .fontSize(13).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)
                    Text(d.productName || '')
                      .fontSize(12).fontColor(Colors.TEXT_SECONDARY).margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start).layoutWeight(1)

                  Column() {
                    Text(getDisputeStatusText(d.status))
                      .fontSize(11)
                      .fontColor(d.status === 'negotiating' ? '#856404' :
                        d.status === 'voting' ? '#1A5276' : '#1E8449')
                      .backgroundColor(d.status === 'negotiating' ? '#FFF3CD' :
                        d.status === 'voting' ? '#D6EAF8' : '#D5F5E3')
                      .borderRadius(4)
                      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    if (d.result) {
                      Text(getDisputeResultText(d.result))
                        .fontSize(10)
                        .fontColor(d.result === 'buyer_win' ? '#922B21' : '#1A5276')
                        .margin({ top: 4 })
                    }
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')

                Row() {
                  Text(`${d.initiatorName} 申请 · 被申请人: ${d.respondentName}`)
                    .fontSize(11).fontColor(Colors.TEXT_HINT)
                }
                .width('100%').margin({ top: 8 })

                if (d.status === 'voting') {
                  Row() {
                    Text(`投票: ${d.buyerVotes} 支持买家 vs ${d.sellerVotes} 支持卖家`)
                      .fontSize(11).fontColor(Colors.PRIMARY)
                  }
                  .width('100%').margin({ top: 4 })
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Colors.BG_WHITE)
              .borderRadius(8)
              .margin({ top: 8 })
              .onClick(() => {
                const p: Record<string, string> = {}
                p['disputeId'] = d.id
                router.pushUrl({ url: Constants.PAGE_DISPUTE_DETAIL, params: p })
              })
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .width('100%').layoutWeight(1).backgroundColor(Colors.BG_PAPER).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%')

    // 新建维权按钮
    Button('发起维权')
      .fontSize(14)
      .backgroundColor(Colors.PRIMARY)
      .borderRadius(22).height(44).width('60%')
      .position({ x: '20%', y: '88%' })
      .shadow({ radius: 8, color: '#40000000' })
      .onClick(() => router.pushUrl({ url: Constants.PAGE_DISPUTE_APPLY }))
  }
}
