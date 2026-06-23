// 订单列表页
import { router } from '@kit.ArkUI'
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
        } else if (order.status === OrderStatus.PENDING_RECEIVE) {
          Button('确认收货')
            .fontSize(12)
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(14)
            .height(28)
            .padding({ left: 12, right: 12 })
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
}
