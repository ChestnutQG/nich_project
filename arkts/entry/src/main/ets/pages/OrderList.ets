// 订单列表页
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Order, OrderStatus, getOrderStatusText, OrderItem } from '../model/Order'
import { OrderService } from '../service/OrderService'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'
import { PriceText } from '../components/PriceText'

interface StatusTab {
  label: string
  status: number
}

@Entry
@Component
struct OrderList {
  @State orders: Order[] = []
  @State currentStatus: number = -1
  @State loading: boolean = true

  // 付款弹窗
  @State showPayModal: boolean = false
  @State payingOrder: Order | undefined = undefined
  @State paying: boolean = false
  @State selectedPayMethod: number = 0  // 0-华为 1-微信 2-支付宝

  private statusTabs: StatusTab[] = [
    { label: '全部', status: -1 },
    { label: '待付款', status: OrderStatus.PENDING_PAY },
    { label: '待发货', status: OrderStatus.PENDING_DELIVER },
    { label: '待收货', status: OrderStatus.PENDING_RECEIVE },
    { label: '已完成', status: OrderStatus.COMPLETED }
  ]

  aboutToAppear(): void {
    this.loadOrders()
  }

  async loadOrders(): Promise<void> {
    this.loading = true
    const resp = await OrderService.fetchOrders(
      this.currentStatus >= 0 ? this.currentStatus as OrderStatus : undefined
    )
    if (resp.code === 0) {
      this.orders = resp.data
    }
    this.loading = false
  }

  getItemCount(order: Order): number {
    let count = 0
    order.items.forEach((i: OrderItem) => { count += i.quantity })
    return count
  }

  build() {
    Stack() {
      Column() {
        NavBar({ title: '我的订单', showBack: true })

        Row() {
          ForEach(this.statusTabs, (tab: StatusTab, index: number) => {
            Text(tab.label)
              .fontSize(13)
              .fontColor(this.currentStatus === tab.status ? Colors.PRIMARY : Colors.TEXT_SECONDARY)
              .fontWeight(this.currentStatus === tab.status ? FontWeight.Medium : FontWeight.Normal)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .padding({ top: 10, bottom: 10 })
              .onClick(() => {
                this.currentStatus = tab.status
                this.loadOrders()
              })
          })
        }
        .width('100%')
        .backgroundColor(Colors.BG_WHITE)

        if (this.loading) {
          Row() {
            LoadingProgress().width(24).height(24).color(Colors.PRIMARY)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.orders.length === 0) {
          EmptyState({ message: '暂无订单', iconText: '📋' })
        } else {
          Scroll() {
            Column() {
              ForEach(this.orders, (order: Order) => {
                this.OrderCard(order)
              })
            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor(Colors.BG_PAPER)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')

      // 付款弹窗
      if (this.showPayModal) {
        this.PayModal()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  OrderCard(order: Order) {
    Column() {
      Row() {
        Text(`订单号：${order.orderNo}`)
          .fontSize(12)
          .fontColor(Colors.TEXT_SECONDARY)
        Blank()
        Text(getOrderStatusText(order.status))
          .fontSize(12)
          .fontColor(Colors.PRIMARY)
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 12, bottom: 8 })

      ForEach(order.items, (item: OrderItem) => {
        Row() {
          Image(item.productImage)
            .width(64)
            .height(64)
            .borderRadius(6)
            .objectFit(ImageFit.Cover)

          Column() {
            Text(item.productName)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.TEXT_PRIMARY)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(item.skuName)
              .fontSize(11)
              .fontColor(Colors.TEXT_SECONDARY)
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .margin({ left: 10 })
          .alignItems(HorizontalAlign.Start)

          Column() {
            PriceText({ price: item.price, textSize: 13 })
            Text(`x${item.quantity}`)
              .fontSize(11)
              .fontColor(Colors.TEXT_HINT)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      })

      Row() {
        Text(`共${this.getItemCount(order)}件  合计：`)
          .fontSize(12)
          .fontColor(Colors.TEXT_SECONDARY)
        PriceText({ price: order.payAmount, textSize: 14 })

        Blank()

        if (order.status === OrderStatus.PENDING_PAY) {
          Button('去付款')
            .fontSize(12)
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(14)
            .height(28)
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.payingOrder = order
              this.selectedPayMethod = 0
              this.showPayModal = true
            })
        } else if (order.status === OrderStatus.PENDING_RECEIVE) {
          Button('确认收货')
            .fontSize(12)
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(14)
            .height(28)
            .padding({ left: 12, right: 12 })
            .onClick(() => { this.handleConfirmReceive(order) })
        } else if (order.status === OrderStatus.PENDING_DELIVER) {
          Button('提醒发货')
            .fontSize(12)
            .backgroundColor(Colors.GOLD)
            .borderRadius(14)
            .height(28)
            .padding({ left: 12, right: 12 })
        }
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 12 })
    }
    .width('100%')
    .backgroundColor(Colors.BG_WHITE)
    .margin({ top: 8 })
    .onClick(() => {
      const p: Record<string, Object> = {}
      p['orderId'] = order.id
      router.pushUrl({ url: Constants.PAGE_ORDER_DETAIL, params: p })
    })
  }

  @Builder
  PayModal() {
    Column() {
      // 遮罩
      Column()
        .width('100%').height('100%')
        .backgroundColor('#4D000000')
        .onClick(() => {
          this.showPayModal = false
          this.payingOrder = undefined
          this.selectedPayMethod = 0
        })
    }

    Column() {
      Text('确认支付')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.TEXT_PRIMARY)
        .margin({ top: 24, bottom: 4 })

      Text('锤子铺 · 模拟收银台')
        .fontSize(13)
        .fontColor(Colors.TEXT_SECONDARY)
        .margin({ bottom: 20 })

      // 支付金额
      Column() {
        Text('支付金额')
          .fontSize(12)
          .fontColor(Colors.TEXT_SECONDARY)
        Text(`¥${((this.payingOrder?.payAmount || 0) / 100).toFixed(2)}`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.PRIMARY)
          .margin({ top: 6 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Colors.PRIMARY_BG)
      .borderRadius(10)
      .margin({ bottom: 16 })

      // 支付方式选择
      Column() {
        Row() {
          Text(this.selectedPayMethod === 0 ? '●' : '○')
            .fontSize(18)
            .fontColor(this.selectedPayMethod === 0 ? Colors.PRIMARY : Colors.TEXT_HINT)
            .margin({ right: 10 })
          Text('💳 华为支付（模拟）')
            .fontSize(14)
            .fontColor(Colors.TEXT_PRIMARY)
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .borderRadius(8)
        .border({ width: 1, color: this.selectedPayMethod === 0 ? Colors.PRIMARY : Colors.DIVIDER })
        .backgroundColor(this.selectedPayMethod === 0 ? Colors.PRIMARY_BG : Color.Transparent)
        .margin({ bottom: 8 })
        .onClick(() => { this.selectedPayMethod = 0 })

        Row() {
          Text(this.selectedPayMethod === 1 ? '●' : '○')
            .fontSize(18)
            .fontColor(this.selectedPayMethod === 1 ? Colors.PRIMARY : Colors.TEXT_HINT)
            .margin({ right: 10 })
          Text('📱 微信支付（模拟）')
            .fontSize(14)
            .fontColor(Colors.TEXT_PRIMARY)
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .borderRadius(8)
        .border({ width: 1, color: this.selectedPayMethod === 1 ? Colors.PRIMARY : Colors.DIVIDER })
        .backgroundColor(this.selectedPayMethod === 1 ? Colors.PRIMARY_BG : Color.Transparent)
        .margin({ bottom: 8 })
        .onClick(() => { this.selectedPayMethod = 1 })

        Row() {
          Text(this.selectedPayMethod === 2 ? '●' : '○')
            .fontSize(18)
            .fontColor(this.selectedPayMethod === 2 ? Colors.PRIMARY : Colors.TEXT_HINT)
            .margin({ right: 10 })
          Text('💴 支付宝（模拟）')
            .fontSize(14)
            .fontColor(Colors.TEXT_PRIMARY)
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .borderRadius(8)
        .border({ width: 1, color: this.selectedPayMethod === 2 ? Colors.PRIMARY : Colors.DIVIDER })
        .backgroundColor(this.selectedPayMethod === 2 ? Colors.PRIMARY_BG : Color.Transparent)
        .margin({ bottom: 8 })
        .onClick(() => { this.selectedPayMethod = 2 })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 按钮
      Button(this.paying ? '支付中...' : '确认支付 ¥' + ((this.payingOrder?.payAmount || 0) / 100).toFixed(2))
        .fontSize(15)
        .backgroundColor(this.paying ? Colors.TEXT_HINT : Colors.PRIMARY)
        .borderRadius(22)
        .height(44)
        .width('100%')
        .onClick(() => {
          if (!this.paying) { this.handlePay() }
        })
        .margin({ bottom: 8 })

      Button('取消')
        .fontSize(14)
        .backgroundColor(Colors.BG_PAPER)
        .fontColor(Colors.TEXT_SECONDARY)
        .borderRadius(22)
        .height(40)
        .width('100%')
        .onClick(() => {
          this.showPayModal = false
          this.payingOrder = undefined
          this.selectedPayMethod = 0
        })
        .margin({ bottom: 24 })
    }
    .width('84%')
    .padding({ left: 20, right: 20 })
    .backgroundColor(Colors.BG_WHITE)
    .borderRadius(16)
    .position({ x: '8%', y: '20%' })
  }

  private async handlePay(): Promise<void> {
    if (!this.payingOrder) return
    this.paying = true
    // 模拟支付延迟
    const resp = await OrderService.updateStatus(this.payingOrder.id, OrderStatus.PENDING_DELIVER)
    this.paying = false
    this.showPayModal = false
    this.payingOrder = undefined
    if (resp.code === 0) {
      promptAction.showToast({ message: '支付成功！' })
      this.loadOrders()
    } else {
      promptAction.showToast({ message: resp.message || '支付失败' })
    }
  }

  private async handleConfirmReceive(order: Order): Promise<void> {
    const resp = await OrderService.updateStatus(order.id, OrderStatus.COMPLETED)
    if (resp.code === 0) {
      promptAction.showToast({ message: '已确认收货' })
      this.loadOrders()
    } else {
      promptAction.showToast({ message: resp.message || '操作失败' })
    }
  }
}
