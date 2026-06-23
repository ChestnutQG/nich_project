// 确认订单页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { NavBar } from '../components/NavBar'
import { PriceText } from '../components/PriceText'

@Entry
@Component
struct OrderConfirm {
  @State addressName: string = '张明'
  @State addressPhone: string = '13912345678'
  @State addressFull: string = '北京市朝阳区建国路88号SOHO现代城A座1201'

  build() {
    Column() {
      NavBar({ title: '确认订单', showBack: true })

      Scroll() {
        Column() {
          // 收货地址
          Row() {
            Text('📍')
              .fontSize(22)
              .margin({ right: 10 })

            Column() {
              Row() {
                Text(this.addressName)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
                Text(this.addressPhone)
                  .fontSize(13)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .margin({ left: 16 })
              }
              Text(this.addressFull)
                .fontSize(13)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ top: 4 })
                .maxLines(2)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(14)
              .height(14)
              .fillColor(Colors.TEXT_HINT)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Colors.BG_WHITE)

          // 商品信息
          Column() {
            Row() {
              Image('https://picsum.photos/seed/nh07/80/80')
                .width(72)
                .height(72)
                .borderRadius(6)
                .objectFit(ImageFit.Cover)

              Column() {
                Text('苗族银饰錾花手镯 · 百鸟朝凤')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text('百鸟朝凤·标准款')
                  .fontSize(11)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .margin({ left: 10 })
              .alignItems(HorizontalAlign.Start)

              Column() {
                PriceText({ price: 56000, textSize: 15 })
                Text('x1')
                  .fontSize(11)
                  .fontColor(Colors.TEXT_HINT)
                  .margin({ top: 4 })
              }
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Colors.BG_WHITE)
          .margin({ top: 8 })

          // 金额汇总
          Column() {
            this.AmountRow('商品总额', 56000)
            this.AmountRow('运费', 0)
            this.AmountRow('优惠', -5000)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Colors.BG_WHITE)
          .margin({ top: 8 })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Colors.BG_PAPER)
      .scrollBar(BarState.Off)

      // 底部提交栏
      Row() {
        Text('实付: ')
          .fontSize(14)
          .fontColor(Colors.TEXT_PRIMARY)
        Text('¥510.00')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.PRIMARY)

        Blank()

        Button('提交订单')
          .fontSize(15)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(20)
          .height(40)
          .width(120)
          .onClick(() => {
            // 模拟下单成功
            router.pushUrl({ url: Constants.PAGE_ORDER_LIST })
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Colors.BG_WHITE)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AmountRow(label: string, amount: number) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(Colors.TEXT_SECONDARY)
      Blank()
      Text(`${amount >= 0 ? '+' : '-'}¥${(Math.abs(amount) / 100).toFixed(2)}`)
        .fontSize(14)
        .fontColor(Colors.TEXT_PRIMARY)
    }
    .width('100%')
    .margin({ top: 6 })
  }
}
