// 购物车页面（独立 @Entry 页面，无底部 Tab 栏）
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { CartService, CartItem } from '../service/CartService'
import { NavBar } from '../components/NavBar'

@Entry
@Component
struct Cart {
  @State items: CartItem[] = []
  @State allChecked: boolean = true
  @State loading: boolean = true

  aboutToAppear(): void {
    this.loadCart()
  }

  onPageShow(): void {
    // 从商品详情加购后返回，刷新最新购物车
    this.loadCart()
  }

  async loadCart(): Promise<void> {
    this.loading = true
    const resp = await CartService.fetchCartList()
    if (resp.code === 0) {
      this.items = resp.data
      this.allChecked = this.items.length > 0 && this.items.every((i: CartItem) => i.isChecked)
    }
    this.loading = false
  }

  calcTotal(): number {
    let sum = 0
    this.items.filter((i: CartItem) => i.isChecked).forEach((i: CartItem) => { sum += i.price * i.quantity })
    return sum
  }

  calcCheckedCount(): number {
    return this.items.filter((i: CartItem) => i.isChecked).length
  }

  build() {
    Column() {
      NavBar({ title: '购物车', showBack: true })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Colors.PRIMARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.items.length === 0) {
        Column() {
          Text('🛒').fontSize(48).margin({ bottom: 12 })
          Text('购物车还是空的').fontSize(14).fontColor(Colors.TEXT_HINT)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.items, (item: CartItem) => {
              Row() {
                Text(item.isChecked ? '☑️' : '⬜')
                  .fontSize(22)
                  .margin({ right: 10 })
                  .onClick(async () => {
                    item.isChecked = !item.isChecked
                    this.items = [...this.items]   // 触发列表刷新
                    this.allChecked = this.items.every((i: CartItem) => i.isChecked)
                    await CartService.updateChecked(item.id, item.isChecked ? 1 : 0)
                  })

                Image(item.productImage)
                  .width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover)

                Column() {
                  Text(item.productName)
                    .fontSize(14).fontWeight(FontWeight.Medium)
                    .fontColor(Colors.TEXT_PRIMARY)
                    .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(item.artisanName)
                    .fontSize(11).fontColor(Colors.TEXT_SECONDARY).margin({ top: 4 })

                  Text(item.skuName)
                    .fontSize(10).fontColor(Colors.TEXT_HINT).margin({ top: 1 })

                  Row() {
                    Text(`¥${(item.price / 100).toFixed(2)}`)
                      .fontSize(15).fontWeight(FontWeight.Bold).fontColor(Colors.PRIMARY)

                    Blank()

                    Row() {
                      Text('-').fontSize(18).fontColor(Colors.TEXT_PRIMARY)
                        .width(28).textAlign(TextAlign.Center)
                        .onClick(async () => {
                          if (item.quantity > 1) {
                            item.quantity--
                            this.items = [...this.items]   // 触发列表刷新
                            await CartService.updateQuantity(item.id, item.quantity)
                          }
                        })
                      Text(`${item.quantity}`).fontSize(14).fontColor(Colors.TEXT_PRIMARY)
                        .width(36).textAlign(TextAlign.Center)
                      Text('+').fontSize(18).fontColor(Colors.TEXT_PRIMARY)
                        .width(28).textAlign(TextAlign.Center)
                        .onClick(async () => {
                          item.quantity++
                          this.items = [...this.items]   // 触发列表刷新
                          await CartService.updateQuantity(item.id, item.quantity)
                        })
                    }
                    .borderRadius(4).border({ width: 1, color: Colors.DIVIDER })
                  }
                  .width('100%').margin({ top: 8 })
                }
                .layoutWeight(1).margin({ left: 10 }).alignItems(HorizontalAlign.Start)
              }
              .width('100%').padding(12).borderRadius(8)
              .backgroundColor(Colors.BG_CARD)
              .margin({ left: 16, right: 16, top: 10 })
            })
          }
        }
        .width('100%').layoutWeight(1)
        .backgroundColor(Colors.BG_PAPER).scrollBar(BarState.Off)
      }

      if (this.items.length > 0) {
        Row() {
          Row() {
            Text(this.allChecked ? '☑️' : '⬜')
              .fontSize(22).margin({ right: 6 })
              .onClick(async () => {
                this.allChecked = !this.allChecked
                this.items.forEach((i: CartItem) => i.isChecked = this.allChecked)
                this.items = [...this.items]   // 触发列表刷新
                await CartService.updateAllChecked(this.allChecked ? 1 : 0)
              })
            Text('全选').fontSize(13).fontColor(Colors.TEXT_SECONDARY)
          }
          Blank()
          Column() {
            Text(`合计: ¥${(this.calcTotal() / 100).toFixed(2)}`)
              .fontSize(16).fontWeight(FontWeight.Bold).fontColor(Colors.PRIMARY)
            Text('不含运费').fontSize(10).fontColor(Colors.TEXT_HINT)
          }
          .alignItems(HorizontalAlign.End).margin({ right: 12 })

          Button(`结算(${this.calcCheckedCount()})`)
            .fontSize(14)
            .backgroundColor(this.calcCheckedCount() > 0 ? Colors.PRIMARY : Colors.TEXT_HINT)
            .borderRadius(20).height(36).width(100)
            .enabled(this.calcCheckedCount() > 0)
            .onClick(() => {
              router.pushUrl({ url: Constants.PAGE_ORDER_CONFIRM })
            })
        }
        .width('100%').height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Colors.BG_WHITE)
      }
    }
    .width('100%').height('100%')
  }
}
