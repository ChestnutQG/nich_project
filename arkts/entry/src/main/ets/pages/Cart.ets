// 购物车页面（独立页面，用于 push 导航）
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Utils } from '../common/Utils'
import { CartService, CartItem } from '../service/CartService'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct Cart {
  @State items: CartItem[] = []
  @State allChecked: boolean = true
  @State loading: boolean = true

  aboutToAppear(): void {
    this.loadCart()
  }

  async loadCart(): Promise<void> {
    this.loading = true
    const resp = await CartService.fetchCartList()
    if (resp.code === 0) {
      this.items = resp.data
      this.allChecked = this.items.length > 0 && this.items.every(i => i.checked)
    }
    this.loading = false
  }

  // 计算选中商品总价
  get totalPrice(): number {
    return this.items.filter(i => i.checked).reduce((sum, i) => sum + i.price * i.quantity, 0)
  }

  // 选中商品数量
  get checkedCount(): number {
    return this.items.filter(i => i.checked).length
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
        EmptyState({ message: '购物车还是空的', iconText: '🛒' })
      } else {
        Scroll() {
          Column() {
            ForEach(this.items, (item: CartItem) => {
              Row() {
                // 勾选框
                Text(item.checked ? '☑️' : '⬜')
                  .fontSize(22)
                  .margin({ right: 10 })
                  .onClick(async () => {
                    item.checked = !item.checked
                    this.allChecked = this.items.every(i => i.checked)
                    await CartService.updateChecked(item.skuId, item.checked)
                  })

                // 商品图片
                Image(item.productImage)
                  .width(80)
                  .height(80)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)

                // 商品信息
                Column() {
                  Text(item.productName)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Colors.TEXT_PRIMARY)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(item.artisanName)
                    .fontSize(11)
                    .fontColor(Colors.TEXT_SECONDARY)
                    .margin({ top: 4 })

                  Text(item.skuName)
                    .fontSize(10)
                    .fontColor(Colors.TEXT_HINT)
                    .margin({ top: 1 })

                  Row() {
                    Text(Utils.formatPrice(item.price))
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Colors.PRIMARY)

                    Blank()

                    // 数量调整
                    Row() {
                      Text('-')
                        .fontSize(18)
                        .fontColor(Colors.TEXT_PRIMARY)
                        .width(28)
                        .textAlign(TextAlign.Center)
                        .onClick(async () => {
                          if (item.quantity > 1) {
                            item.quantity--
                            await CartService.updateQuantity(item.skuId, item.quantity)
                          }
                        })
                      Text(`${item.quantity}`)
                        .fontSize(14)
                        .fontColor(Colors.TEXT_PRIMARY)
                        .width(36)
                        .textAlign(TextAlign.Center)
                      Text('+')
                        .fontSize(18)
                        .fontColor(Colors.TEXT_PRIMARY)
                        .width(28)
                        .textAlign(TextAlign.Center)
                        .onClick(async () => {
                          item.quantity++
                          await CartService.updateQuantity(item.skuId, item.quantity)
                        })
                    }
                    .borderRadius(4)
                    .border({ width: 1, color: Colors.DIVIDER })
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .layoutWeight(1)
                .margin({ left: 10 })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .borderRadius(8)
              .backgroundColor(Colors.BG_CARD)
              .margin({ left: 16, right: 16, top: 10 })
            })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Colors.BG_PAPER)
        .scrollBar(BarState.Off)
      }

      // 底部结算栏
      if (this.items.length > 0) {
        Row() {
          Row() {
            Text(this.allChecked ? '☑️' : '⬜')
              .fontSize(22)
              .margin({ right: 6 })
              .onClick(async () => {
                this.allChecked = !this.allChecked
                this.items.forEach(i => i.checked = this.allChecked)
                await CartService.updateAllChecked(this.allChecked)
              })
            Text('全选')
              .fontSize(13)
              .fontColor(Colors.TEXT_SECONDARY)
          }

          Blank()

          Column() {
            Text(`合计: ${Utils.formatPrice(this.totalPrice)}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.PRIMARY)
            Text(`不含运费`)
              .fontSize(10)
              .fontColor(Colors.TEXT_HINT)
          }
          .alignItems(HorizontalAlign.End)
          .margin({ right: 12 })

          Button(`结算(${this.checkedCount})`)
            .fontSize(14)
            .backgroundColor(this.checkedCount > 0 ? Colors.PRIMARY : Colors.TEXT_HINT)
            .borderRadius(20)
            .height(36)
            .width(100)
            .enabled(this.checkedCount > 0)
            .onClick(() => {
              router.pushUrl({ url: Constants.PAGE_ORDER_CONFIRM })
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Colors.BG_WHITE)
      }
    }
    .width('100%')
    .height('100%')
  }
}
