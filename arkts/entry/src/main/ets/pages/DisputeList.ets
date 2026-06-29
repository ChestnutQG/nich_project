// 纠纷列表页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { DisputeService } from '../service/DisputeService'
import { Dispute, getDisputeStatusText, getDisputeResultText } from '../model/Dispute'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct DisputeList {
  @State disputes: Dispute[] = []
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
      NavBar({ title: this.t('我的维权', 'My Disputes'), showBack: true })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Theme.primary(this.theme))
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else if (this.disputes.length === 0) {
        EmptyState({ message: this.t('暂无维权记录', 'No disputes'), iconText: '⚖️' })
      } else {
        Scroll() {
          Column() {
            ForEach(this.disputes, (d: Dispute) => {
              Column() {
                Row() {
                  Column() {
                    Text(d.orderNo || '')
                      .fontSize(this.fs(13)).fontWeight(FontWeight.Medium).fontColor(Theme.textPrimary(this.theme))
                    Text(d.productName || '')
                      .fontSize(this.fs(12)).fontColor(Theme.textSecondary(this.theme)).margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start).layoutWeight(1)

                  Column() {
                    Text(getDisputeStatusText(d.status))
                      .fontSize(this.fs(11))
                      .fontColor(d.status === 'negotiating' ? '#856404' :
                        d.status === 'voting' ? '#1A5276' : '#1E8449')
                      .backgroundColor(d.status === 'negotiating' ? '#FFF3CD' :
                        d.status === 'voting' ? '#D6EAF8' : '#D5F5E3')
                      .borderRadius(4)
                      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    if (d.result) {
                      Text(getDisputeResultText(d.result))
                        .fontSize(this.fs(10))
                        .fontColor(d.result === 'buyer_win' ? '#922B21' : '#1A5276')
                        .margin({ top: 4 })
                    }
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')

                Row() {
                  Text(`${d.initiatorName} ${this.t('申请 · 被申请人', 'applied · Respondent')}: ${d.respondentName}`)
                    .fontSize(this.fs(11)).fontColor(Theme.textHint(this.theme))
                }
                .width('100%').margin({ top: 8 })

                if (d.status === 'voting') {
                  Row() {
                    Text(`${this.t('投票', 'Votes')}: ${d.buyerVotes} ${this.t('支持买家', 'buyer')} vs ${d.sellerVotes} ${this.t('支持卖家', 'seller')}`)
                      .fontSize(this.fs(11)).fontColor(Theme.primary(this.theme))
                  }
                  .width('100%').margin({ top: 4 })
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.card(this.theme))
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
        .width('100%').layoutWeight(1).backgroundColor(Theme.bg(this.theme)).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.bg(this.theme))

    Button(this.t('发起维权', 'New Dispute'))
      .fontSize(this.fs(14))
      .backgroundColor(Theme.primary(this.theme))
      .borderRadius(22).height(44).width('60%')
      .position({ x: '20%', y: '88%' })
      .shadow({ radius: 8, color: '#40000000' })
      .onClick(() => router.pushUrl({ url: Constants.PAGE_DISPUTE_APPLY }))
  }
}
