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
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

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

  @State showPayModal: boolean = false
  @State payingOrder: Order | undefined = undefined
  @State paying: boolean = false
  @State selectedPayMethod: number = 0

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

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
        NavBar({ title: this.t('我的订单', 'My Orders'), showBack: true })

        Row() {
          ForEach(this.statusTabs, (tab: StatusTab, index: number) => {
            Text(tab.label)
              .fontSize(this.fs(13))
              .fontColor(this.currentStatus === tab.status ? Theme.primary(this.theme) : Theme.textSecondary(this.theme))
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
        .backgroundColor(Theme.card(this.theme))

        if (this.loading) {
          Row() {
            LoadingProgress().width(24).height(24).color(Theme.primary(this.theme))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.bg(this.theme))
        } else if (this.orders.length === 0) {
          EmptyState({ message: this.t('暂无订单', 'No orders'), iconText: '📋' })
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
          .backgroundColor(Theme.bg(this.theme))
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.bg(this.theme))

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
        Text(`${this.t('订单号', 'Order')}：${order.orderNo}`)
          .fontSize(this.fs(12))
          .fontColor(Theme.textSecondary(this.theme))
        Blank()
        Text(getOrderStatusText(order.status))
          .fontSize(this.fs(12))
          .fontColor(Theme.primary(this.theme))
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
              .fontSize(this.fs(13))
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.textPrimary(this.theme))
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(item.skuName)
              .fontSize(this.fs(11))
              .fontColor(Theme.textSecondary(this.theme))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .margin({ left: 10 })
          .alignItems(HorizontalAlign.Start)

          Column() {
            PriceText({ price: item.price, textSize: 13 })
            Text(`x${item.quantity}`)
              .fontSize(this.fs(11))
              .fontColor(Theme.textHint(this.theme))
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      })

      Row() {
        Text(`${this.t('共', '')}${this.getItemCount(order)}${this.t('件  合计：', ' items  Total: ')}`)
          .fontSize(this.fs(12))
          .fontColor(Theme.textSecondary(this.theme))
        PriceText({ price: order.payAmount, textSize: 14 })

        Blank()

        if (order.status === OrderStatus.PENDING_PAY) {
          Button(this.t('去付款', 'Pay Now'))
            .fontSize(this.fs(12))
            .backgroundColor(Theme.primary(this.theme))
            .borderRadius(14)
            .height(28)
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.payingOrder = order
              this.selectedPayMethod = 0
              this.showPayModal = true
            })
        } else if (order.status === OrderStatus.PENDING_RECEIVE) {
          Button(this.t('确认收货', 'Confirm Receipt'))
            .fontSize(this.fs(12))
            .backgroundColor(Theme.primary(this.theme))
            .borderRadius(14)
            .height(28)
            .padding({ left: 12, right: 12 })
            .onClick(() => { this.handleConfirmReceive(order) })
        } else if (order.status === OrderStatus.PENDING_DELIVER) {
          Button(this.t('提醒发货', 'Remind'))
            .fontSize(this.fs(12))
            .backgroundColor(Theme.gold(this.theme))
            .borderRadius(14)
            .height(28)
            .padding({ left: 12, right: 12 })
        }
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 12 })
    }
    .width('100%')
    .backgroundColor(Theme.card(this.theme))
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
      Text(this.t('确认支付', 'Confirm Payment'))
        .fontSize(this.fs(18))
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.textPrimary(this.theme))
        .margin({ top: 24, bottom: 4 })

      Text(this.t('锤子铺 · 模拟收银台', 'Chuizhi · Simulated Checkout'))
        .fontSize(this.fs(13))
        .fontColor(Theme.textSecondary(this.theme))
        .margin({ bottom: 20 })

      Column() {
        Text(this.t('支付金额', 'Amount'))
          .fontSize(this.fs(12))
          .fontColor(Theme.textSecondary(this.theme))
        Text(`¥${((this.payingOrder?.payAmount || 0) / 100).toFixed(2)}`)
          .fontSize(this.fs(32))
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.primary(this.theme))
          .margin({ top: 6 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Theme.primaryBg(this.theme))
      .borderRadius(10)
      .margin({ bottom: 16 })

      Column() {
        Row() {
          Text(this.selectedPayMethod === 0 ? '●' : '○')
            .fontSize(this.fs(18))
            .fontColor(this.selectedPayMethod === 0 ? Theme.primary(this.theme) : Theme.textHint(this.theme))
            .margin({ right: 10 })
          Text(this.t('💳 华为支付（模拟）', '💳 Huawei Pay (Simulated)'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textPrimary(this.theme))
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .borderRadius(8)
        .border({ width: 1, color: this.selectedPayMethod === 0 ? Theme.primary(this.theme) : Theme.divider(this.theme) })
        .backgroundColor(this.selectedPayMethod === 0 ? Theme.primaryBg(this.theme) : Color.Transparent)
        .margin({ bottom: 8 })
        .onClick(() => { this.selectedPayMethod = 0 })

        Row() {
          Text(this.selectedPayMethod === 1 ? '●' : '○')
            .fontSize(this.fs(18))
            .fontColor(this.selectedPayMethod === 1 ? Theme.primary(this.theme) : Theme.textHint(this.theme))
            .margin({ right: 10 })
          Text(this.t('📱 微信支付（模拟）', '📱 WeChat Pay (Simulated)'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textPrimary(this.theme))
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .borderRadius(8)
        .border({ width: 1, color: this.selectedPayMethod === 1 ? Theme.primary(this.theme) : Theme.divider(this.theme) })
        .backgroundColor(this.selectedPayMethod === 1 ? Theme.primaryBg(this.theme) : Color.Transparent)
        .margin({ bottom: 8 })
        .onClick(() => { this.selectedPayMethod = 1 })

        Row() {
          Text(this.selectedPayMethod === 2 ? '●' : '○')
            .fontSize(this.fs(18))
            .fontColor(this.selectedPayMethod === 2 ? Theme.primary(this.theme) : Theme.textHint(this.theme))
            .margin({ right: 10 })
          Text(this.t('💴 支付宝（模拟）', '💴 Alipay (Simulated)'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textPrimary(this.theme))
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .borderRadius(8)
        .border({ width: 1, color: this.selectedPayMethod === 2 ? Theme.primary(this.theme) : Theme.divider(this.theme) })
        .backgroundColor(this.selectedPayMethod === 2 ? Theme.primaryBg(this.theme) : Color.Transparent)
        .margin({ bottom: 8 })
        .onClick(() => { this.selectedPayMethod = 2 })
      }
      .width('100%')
      .margin({ bottom: 20 })

      Button(this.paying
        ? this.t('支付中...', 'Processing...')
        : `${this.t('确认支付', 'Pay')} ¥${((this.payingOrder?.payAmount || 0) / 100).toFixed(2)}`)
        .fontSize(this.fs(15))
        .backgroundColor(this.paying ? Theme.textHint(this.theme) : Theme.primary(this.theme))
        .borderRadius(22)
        .height(44)
        .width('100%')
        .onClick(() => {
          if (!this.paying) { this.handlePay() }
        })
        .margin({ bottom: 8 })

      Button(this.t('取消', 'Cancel'))
        .fontSize(this.fs(14))
        .backgroundColor(Theme.bg(this.theme))
        .fontColor(Theme.textSecondary(this.theme))
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
    .backgroundColor(Theme.card(this.theme))
    .borderRadius(16)
    .position({ x: '8%', y: '20%' })
  }

  private async handlePay(): Promise<void> {
    if (!this.payingOrder) return
    this.paying = true
    const resp = await OrderService.updateStatus(this.payingOrder.id, OrderStatus.PENDING_DELIVER)
    this.paying = false
    this.showPayModal = false
    this.payingOrder = undefined
    if (resp.code === 0) {
      promptAction.showToast({ message: this.t('支付成功！', 'Payment successful!') })
      this.loadOrders()
    } else {
      promptAction.showToast({ message: resp.message || this.t('支付失败', 'Payment failed') })
    }
  }

  private async handleConfirmReceive(order: Order): Promise<void> {
    const resp = await OrderService.updateStatus(order.id, OrderStatus.COMPLETED)
    if (resp.code === 0) {
      promptAction.showToast({ message: this.t('已确认收货', 'Receipt confirmed') })
      this.loadOrders()
    } else {
      promptAction.showToast({ message: resp.message || this.t('操作失败', 'Failed') })
    }
  }
}
