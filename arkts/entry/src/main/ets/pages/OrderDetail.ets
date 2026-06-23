// 订单详情页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Utils } from '../common/Utils'
import { Order, OrderStatus, getOrderStatusText, OrderItem } from '../model/Order'
import { OrderService } from '../service/OrderService'
import { NavBar } from '../components/NavBar'

@Entry
@Component
struct OrderDetail {
  @State order: Order | undefined = undefined
  @State loading: boolean = true
  private orderId: string = ''

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
      NavBar({ title: '订单详情', showBack: true })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Colors.PRIMARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (!this.order) {
        Column() {
          Text('订单不存在').fontSize(14).fontColor(Colors.TEXT_HINT)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 状态卡
            Column() {
              Text(getOrderStatusText(this.order!.status))
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.PRIMARY)
            }
            .width('100%')
            .padding(24)
            .backgroundColor(Colors.PRIMARY_BG)

            // 收货地址
            Column() {
              Row() {
                Text('📍').fontSize(16).margin({ right: 8 })
                Text('收货地址').fontSize(14).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)
              }
              .width('100%')

              Text(`${this.order!.address.name}  ${this.order!.address.phone}`)
                .fontSize(13)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ top: 8 })

              Text(`${this.order!.address.province}${this.order!.address.city}${this.order!.address.district} ${this.order!.address.detail}`)
                .fontSize(12)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ top: 4 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Colors.BG_WHITE)
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
                      .fontSize(13)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Colors.TEXT_PRIMARY)
                      .maxLines(2)
                    Text(item.skuName)
                      .fontSize(11)
                      .fontColor(Colors.TEXT_SECONDARY)
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .margin({ left: 10 })
                  .alignItems(HorizontalAlign.Start)

                  Column() {
                    Text(`¥${(item.price / 100).toFixed(2)}`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Colors.PRIMARY)
                    Text(`x${item.quantity}`)
                      .fontSize(11)
                      .fontColor(Colors.TEXT_HINT)
                      .margin({ top: 4 })
                  }
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
              })

              Divider().color(Colors.DIVIDER)

              // 金额汇总
              this.PriceRow('商品总额', this.order!.totalAmount)
              this.PriceRow('优惠', -this.order!.discountAmount)
              this.PriceRow('运费', this.order!.freight)
              Row() {
                Text('实付金额')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
                Blank()
                Text(`¥${(this.order!.payAmount / 100).toFixed(2)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.PRIMARY)
              }
              .width('100%')
              .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Colors.BG_WHITE)
            .margin({ top: 8 })

            // 订单信息
            Column() {
              this.InfoRow('订单编号', this.order!.orderNo)
              this.InfoRow('创建时间', Utils.formatDate(this.order!.createTime))
              if (this.order!.payTime) {
                this.InfoRow('付款时间', Utils.formatDate(this.order!.payTime))
              }
              if (this.order!.deliverTime) {
                this.InfoRow('发货时间', Utils.formatDate(this.order!.deliverTime))
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Colors.BG_WHITE)
            .margin({ top: 8 })

            Row().height(48)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Colors.BG_PAPER)
        .scrollBar(BarState.Off)

        // 底部操作
        if (this.order!.status === OrderStatus.PENDING_PAY) {
          Row() {
            Button('取消订单')
              .fontSize(14)
              .backgroundColor(Colors.BG_CARD)
              .fontColor(Colors.TEXT_SECONDARY)
              .borderRadius(20)
              .height(40)
              .layoutWeight(1)
              .margin({ right: 12 })
            Button('立即付款')
              .fontSize(14)
              .backgroundColor(Colors.PRIMARY)
              .borderRadius(20)
              .height(40)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(Colors.BG_WHITE)
        }
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PriceRow(label: string, amount: number) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor(Colors.TEXT_SECONDARY)
      Blank()
      Text(`${amount >= 0 ? '+' : '-'}¥${(Math.abs(amount) / 100).toFixed(2)}`)
        .fontSize(13)
        .fontColor(Colors.TEXT_PRIMARY)
    }
    .width('100%')
    .margin({ top: 4 })
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor(Colors.TEXT_SECONDARY)
        .width(72)
      Text(value)
        .fontSize(12)
        .fontColor(Colors.TEXT_PRIMARY)
    }
    .width('100%')
    .margin({ top: 6 })
  }
}
