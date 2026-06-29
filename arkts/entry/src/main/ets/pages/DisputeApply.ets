// 发起维权页面
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { OrderService } from '../service/OrderService'
import { DisputeService } from '../service/DisputeService'
import { Order, OrderStatus, getOrderStatusText } from '../model/Order'
import { NavBar } from '../components/NavBar'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct DisputeApply {
  @State orders: Order[] = []
  @State loading: boolean = true
  @State selectedOrder: Order | undefined = undefined
  @State reason: string = ''
  @State submitting: boolean = false

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
    this.loadOrders()
  }

  async loadOrders(): Promise<void> {
    this.loading = true
    let resp = await OrderService.fetchOrders(OrderStatus.PENDING_RECEIVE)
    if (resp.code === 0) {
      this.orders = resp.data
    }
    resp = await OrderService.fetchOrders(OrderStatus.COMPLETED)
    if (resp.code === 0) {
      this.orders = this.orders.concat(resp.data)
    }
    this.loading = false
  }

  async handleSubmit(): Promise<void> {
    if (!this.selectedOrder) {
      promptAction.showToast({ message: this.t('请选择订单', 'Please select an order') })
      return
    }
    if (!this.reason.trim()) {
      promptAction.showToast({ message: this.t('请填写维权原因', 'Please describe your issue') })
      return
    }
    this.submitting = true
    const resp = await DisputeService.create(this.selectedOrder.id, this.reason.trim(), '[]')
    this.submitting = false
    if (resp.code === 0) {
      promptAction.showToast({ message: this.t('维权申请已提交', 'Dispute submitted') })
      router.back()
    } else {
      promptAction.showToast({ message: resp.message || this.t('提交失败', 'Submission failed') })
    }
  }

  build() {
    Column() {
      NavBar({ title: this.t('发起维权', 'File Dispute'), showBack: true })

      Scroll() {
        Column() {
          Text(this.t('选择要维权的订单', 'Select order'))
            .fontSize(this.fs(14)).fontWeight(FontWeight.Medium).fontColor(Theme.textPrimary(this.theme))
            .width('100%').margin({ bottom: 8 })

          if (this.loading) {
            Row() {
              LoadingProgress().width(20).height(20).color(Theme.primary(this.theme))
            }
            .width('100%').padding(20).justifyContent(FlexAlign.Center)
          } else if (this.orders.length === 0) {
            Text(this.t('暂无可维权的订单', 'No eligible orders'))
              .fontSize(this.fs(13)).fontColor(Theme.textHint(this.theme))
              .width('100%').padding(20).textAlign(TextAlign.Center)
          } else {
            ForEach(this.orders, (order: Order) => {
              Column() {
                Row() {
                  Text(this.selectedOrder?.id === order.id ? '●' : '○')
                    .fontSize(this.fs(18))
                    .fontColor(this.selectedOrder?.id === order.id ? Theme.primary(this.theme) : Theme.textHint(this.theme))
                    .margin({ right: 10 })

                  Column() {
                    Text(order.orderNo)
                      .fontSize(this.fs(13)).fontWeight(FontWeight.Medium).fontColor(Theme.textPrimary(this.theme))
                    Text(getOrderStatusText(order.status))
                      .fontSize(this.fs(11)).fontColor(Theme.textSecondary(this.theme)).margin({ top: 2 })
                    if (order.items && order.items.length > 0) {
                      Text(order.items.map(it => it.productName).join('、'))
                        .fontSize(this.fs(11)).fontColor(Theme.textHint(this.theme)).maxLines(2).margin({ top: 2 })
                    }
                  }
                  .alignItems(HorizontalAlign.Start).layoutWeight(1)
                }
                .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.card(this.theme))
              .borderRadius(8)
              .border({ width: 1, color: this.selectedOrder?.id === order.id ? Theme.primary(this.theme) : Theme.divider(this.theme) })
              .margin({ bottom: 8 })
              .onClick(() => { this.selectedOrder = order })
            })
          }

          Text(this.t('维权原因', 'Reason'))
            .fontSize(this.fs(14)).fontWeight(FontWeight.Medium).fontColor(Theme.textPrimary(this.theme))
            .width('100%').margin({ top: 20, bottom: 8 })

          TextArea({ placeholder: this.t('请详细描述您遇到的问题...', 'Describe your issue in detail...') })
            .height(120)
            .fontSize(this.fs(14))
            .backgroundColor(Theme.card(this.theme))
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => { this.reason = value })

          Button(this.submitting ? this.t('提交中...', 'Submitting...') : this.t('提交维权申请', 'Submit Dispute'))
            .fontSize(this.fs(15))
            .backgroundColor(this.submitting ? Theme.textHint(this.theme) : Theme.primary(this.theme))
            .borderRadius(22).height(44).width('100%')
            .margin({ top: 24 })
            .onClick(() => { if (!this.submitting) this.handleSubmit() })
        }
        .padding(16)
      }
      .width('100%').layoutWeight(1).backgroundColor(Theme.bg(this.theme)).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }
}
