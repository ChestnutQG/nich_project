// 订单详情页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Utils } from '../common/Utils'
import { Order, OrderStatus, getOrderStatusText, OrderItem } from '../model/Order'
import { OrderService } from '../service/OrderService'
import { NavBar } from '../components/NavBar'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct OrderDetail {
  @State order: Order | undefined = undefined
  @State loading: boolean = true
  private orderId: string = ''

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
    if (params && params['orderId']) {
      this.orderId = params['orderId']
      this.loadDetail()
    }
  }

  async loadDetail(): Promise<void> {
    const resp = await OrderService.fetchOrderDetail(this.orderId)
    if (resp.code === 0 && resp.data) {
      this.order = resp.data
    }
    this.loading = false
  }

  build() {
    Column() {
      NavBar({ title: this.t('订单详情', 'Order Detail'), showBack: true })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Theme.primary(this.theme))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else if (!this.order) {
        Column() {
          Text(this.t('订单不存在', 'Order not found'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textHint(this.theme))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else {
        Scroll() {
          Column() {
            // 状态卡
            Column() {
              Text(getOrderStatusText(this.order!.status))
                .fontSize(this.fs(22))
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.primary(this.theme))
            }
            .width('100%')
            .padding(24)
            .backgroundColor(Theme.primaryBg(this.theme))

            // 收货地址
            Column() {
              Row() {
                Text('📍').fontSize(this.fs(16)).margin({ right: 8 })
                Text(this.t('收货地址', 'Shipping Address'))
                  .fontSize(this.fs(14))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme))
              }
              .width('100%')

              Text(`${this.order!.address.name}  ${this.order!.address.phone}`)
                .fontSize(this.fs(13))
                .fontColor(Theme.textPrimary(this.theme))
                .margin({ top: 8 })

              Text(`${this.order!.address.province}${this.order!.address.city}${this.order!.address.district} ${this.order!.address.detail}`)
                .fontSize(this.fs(12))
                .fontColor(Theme.textSecondary(this.theme))
                .margin({ top: 4 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card(this.theme))
            .margin({ top: 8 })

            // 商品列表
            Column() {
              ForEach(this.order!.items, (item: OrderItem) => {
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
                    Text(item.skuName)
                      .fontSize(this.fs(11))
                      .fontColor(Theme.textSecondary(this.theme))
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .margin({ left: 10 })
                  .alignItems(HorizontalAlign.Start)

                  Column() {
                    Text(`¥${(item.price / 100).toFixed(2)}`)
                      .fontSize(this.fs(14))
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.primary(this.theme))
                    Text(`x${item.quantity}`)
                      .fontSize(this.fs(11))
                      .fontColor(Theme.textHint(this.theme))
                      .margin({ top: 4 })
                  }
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
              })

              Divider().color(Theme.divider(this.theme))

              // 金额汇总
              this.PriceRow(this.t('商品总额', 'Subtotal'), this.order!.totalAmount)
              this.PriceRow(this.t('优惠', 'Discount'), -this.order!.discountAmount)
              this.PriceRow(this.t('运费', 'Shipping'), this.order!.freight)
              Row() {
                Text(this.t('实付金额', 'Amount Paid'))
                  .fontSize(this.fs(15))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme))
                Blank()
                Text(`¥${(this.order!.payAmount / 100).toFixed(2)}`)
                  .fontSize(this.fs(18))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.primary(this.theme))
              }
              .width('100%')
              .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card(this.theme))
            .margin({ top: 8 })

            // 订单信息
            Column() {
              this.InfoRow(this.t('订单编号', 'Order No.'), this.order!.orderNo)
              this.InfoRow(this.t('创建时间', 'Created'), Utils.formatDate(this.order!.createTime))
              if (this.order!.payTime) {
                this.InfoRow(this.t('付款时间', 'Paid At'), Utils.formatDate(this.order!.payTime))
              }
              if (this.order!.deliverTime) {
                this.InfoRow(this.t('发货时间', 'Shipped At'), Utils.formatDate(this.order!.deliverTime))
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card(this.theme))
            .margin({ top: 8 })

            Row().height(48)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Theme.bg(this.theme))
        .scrollBar(BarState.Off)

        // 底部操作
        if (this.order!.status === OrderStatus.PENDING_PAY) {
          Row() {
            Button(this.t('取消订单', 'Cancel'))
              .fontSize(this.fs(14))
              .backgroundColor(Theme.card(this.theme))
              .fontColor(Theme.textSecondary(this.theme))
              .borderRadius(20)
              .height(40)
              .layoutWeight(1)
              .margin({ right: 12 })
            Button(this.t('立即付款', 'Pay Now'))
              .fontSize(this.fs(14))
              .backgroundColor(Theme.primary(this.theme))
              .borderRadius(20)
              .height(40)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(Theme.card(this.theme))
        }
        if (this.order!.status === OrderStatus.PENDING_RECEIVE ||
            this.order!.status === OrderStatus.COMPLETED) {
          Row() {
            Button(this.t('申请维权', 'Dispute'))
              .fontSize(this.fs(14))
              .backgroundColor(Theme.warning(this.theme))
              .borderRadius(20)
              .height(40)
              .layoutWeight(1)
              .onClick(() => {
                router.pushUrl({ url: Constants.PAGE_DISPUTE_APPLY })
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(Theme.card(this.theme))
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }

  @Builder
  PriceRow(label: string, amount: number) {
    Row() {
      Text(label)
        .fontSize(this.fs(13))
        .fontColor(Theme.textSecondary(this.theme))
      Blank()
      Text(`${amount >= 0 ? '+' : '-'}¥${(Math.abs(amount) / 100).toFixed(2)}`)
        .fontSize(this.fs(13))
        .fontColor(Theme.textPrimary(this.theme))
    }
    .width('100%')
    .margin({ top: 4 })
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(this.fs(12))
        .fontColor(Theme.textSecondary(this.theme))
        .width(72)
      Text(value)
        .fontSize(this.fs(12))
        .fontColor(Theme.textPrimary(this.theme))
    }
    .width('100%')
    .margin({ top: 6 })
  }
}
