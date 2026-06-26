// 发起维权页面
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { OrderService } from '../service/OrderService'
import { DisputeService } from '../service/DisputeService'
import { Order, OrderStatus, getOrderStatusText } from '../model/Order'
import { NavBar } from '../components/NavBar'

@Entry
@Component
struct DisputeApply {
  @State orders: Order[] = []
  @State loading: boolean = true
  @State selectedOrder: Order | undefined = undefined
  @State reason: string = ''
  @State submitting: boolean = false

  aboutToAppear(): void {
    this.loadOrders()
  }

  async loadOrders(): Promise<void> {
    this.loading = true
    // 只加载待收货(2)和已完成(3)的订单（可发起维权）
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
      promptAction.showToast({ message: '请选择订单' })
      return
    }
    if (!this.reason.trim()) {
      promptAction.showToast({ message: '请填写维权原因' })
      return
    }
    this.submitting = true
    const resp = await DisputeService.create(this.selectedOrder.id, this.reason.trim(), '[]')
    this.submitting = false
    if (resp.code === 0) {
      promptAction.showToast({ message: '维权申请已提交' })
      router.back()
    } else {
      promptAction.showToast({ message: resp.message || '提交失败' })
    }
  }

  build() {
    Column() {
      NavBar({ title: '发起维权', showBack: true })

      Scroll() {
        Column() {
          // 选择订单
          Text('选择要维权的订单')
            .fontSize(14).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)
            .width('100%').margin({ bottom: 8 })

          if (this.loading) {
            Row() {
              LoadingProgress().width(20).height(20).color(Colors.PRIMARY)
            }
            .width('100%').padding(20).justifyContent(FlexAlign.Center)
          } else if (this.orders.length === 0) {
            Text('暂无可维权的订单').fontSize(13).fontColor(Colors.TEXT_HINT)
              .width('100%').padding(20).textAlign(TextAlign.Center)
          } else {
            ForEach(this.orders, (order: Order) => {
              Column() {
                Row() {
                  Text(this.selectedOrder?.id === order.id ? '●' : '○')
                    .fontSize(18)
                    .fontColor(this.selectedOrder?.id === order.id ? Colors.PRIMARY : Colors.TEXT_HINT)
                    .margin({ right: 10 })

                  Column() {
                    Text(order.orderNo)
                      .fontSize(13).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)
                    Text(getOrderStatusText(order.status))
                      .fontSize(11).fontColor(Colors.TEXT_SECONDARY).margin({ top: 2 })
                    if (order.items && order.items.length > 0) {
                      Text(order.items.map(it => it.productName).join('、'))
                        .fontSize(11).fontColor(Colors.TEXT_HINT).maxLines(2).margin({ top: 2 })
                    }
                  }
                  .alignItems(HorizontalAlign.Start).layoutWeight(1)
                }
                .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Colors.BG_WHITE)
              .borderRadius(8)
              .border({ width: 1, color: this.selectedOrder?.id === order.id ? Colors.PRIMARY : Colors.DIVIDER })
              .margin({ bottom: 8 })
              .onClick(() => { this.selectedOrder = order })
            })
          }

          // 维权原因
          Text('维权原因')
            .fontSize(14).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)
            .width('100%').margin({ top: 20, bottom: 8 })

          TextArea({ placeholder: '请详细描述您遇到的问题...' })
            .height(120)
            .fontSize(14)
            .backgroundColor(Colors.BG_WHITE)
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => { this.reason = value })

          // 提交按钮
          Button(this.submitting ? '提交中...' : '提交维权申请')
            .fontSize(15)
            .backgroundColor(this.submitting ? Colors.TEXT_HINT : Colors.PRIMARY)
            .borderRadius(22).height(44).width('100%')
            .margin({ top: 24 })
            .onClick(() => { if (!this.submitting) this.handleSubmit() })
        }
        .padding(16)
      }
      .width('100%').layoutWeight(1).backgroundColor(Colors.BG_PAPER).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
  }
}
