// 购物车页面（独立 @Entry 页面，无底部 Tab 栏）
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { CartService, CartItem } from '../service/CartService'
import { NavBar } from '../components/NavBar'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct Cart {
  @State items: CartItem[] = []
  @State allChecked: boolean = true
  @State loading: boolean = true

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
    this.loadCart()
  }

  onPageShow(): void {
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
      NavBar({ title: this.t('购物车', 'Cart'), showBack: true })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Theme.primary(this.theme))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else if (this.items.length === 0) {
        Column() {
          Text('🛒').fontSize(this.fs(48)).margin({ bottom: 12 })
          Text(this.t('购物车还是空的', 'Your cart is empty')).fontSize(this.fs(14)).fontColor(Theme.textHint(this.theme))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else {
        Scroll() {
          Column() {
            ForEach(this.items, (item: CartItem) => {
              Row() {
                Text(item.isChecked ? '☑️' : '⬜')
                  .fontSize(this.fs(22))
                  .margin({ right: 10 })
                  .onClick(async () => {
                    item.isChecked = !item.isChecked
                    this.items = [...this.items]
                    this.allChecked = this.items.every((i: CartItem) => i.isChecked)
                    await CartService.updateChecked(item.id, item.isChecked ? 1 : 0)
                  })

                Image(item.productImage)
                  .width(80).height(80).borderRadius(8).objectFit(ImageFit.Cover)

                Column() {
                  Text(item.productName)
                    .fontSize(this.fs(14)).fontWeight(FontWeight.Medium)
                    .fontColor(Theme.textPrimary(this.theme))
                    .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(item.artisanName)
                    .fontSize(this.fs(11)).fontColor(Theme.textSecondary(this.theme)).margin({ top: 4 })

                  Text(item.skuName)
                    .fontSize(this.fs(10)).fontColor(Theme.textHint(this.theme)).margin({ top: 1 })

                  Row() {
                    Text(`¥${(item.price / 100).toFixed(2)}`)
                      .fontSize(this.fs(15)).fontWeight(FontWeight.Bold).fontColor(Theme.primary(this.theme))

                    Blank()

                    Row() {
                      Text('-').fontSize(this.fs(18)).fontColor(Theme.textPrimary(this.theme))
                        .width(28).textAlign(TextAlign.Center)
                        .onClick(async () => {
                          if (item.quantity > 1) {
                            item.quantity--
                            this.items = [...this.items]
                            await CartService.updateQuantity(item.id, item.quantity)
                          }
                        })
                      Text(`${item.quantity}`).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
                        .width(36).textAlign(TextAlign.Center)
                      Text('+').fontSize(this.fs(18)).fontColor(Theme.textPrimary(this.theme))
                        .width(28).textAlign(TextAlign.Center)
                        .onClick(async () => {
                          item.quantity++
                          this.items = [...this.items]
                          await CartService.updateQuantity(item.id, item.quantity)
                        })
                    }
                    .borderRadius(4).border({ width: 1, color: Theme.divider(this.theme) })
                  }
                  .width('100%').margin({ top: 8 })
                }
                .layoutWeight(1).margin({ left: 10 }).alignItems(HorizontalAlign.Start)
              }
              .width('100%').padding(12).borderRadius(8)
              .backgroundColor(Theme.card(this.theme))
              .margin({ left: 16, right: 16, top: 10 })
            })
          }
        }
        .width('100%').layoutWeight(1)
        .backgroundColor(Theme.bg(this.theme)).scrollBar(BarState.Off)
      }

      if (this.items.length > 0) {
        Row() {
          Row() {
            Text(this.allChecked ? '☑️' : '⬜')
              .fontSize(this.fs(22)).margin({ right: 6 })
              .onClick(async () => {
                this.allChecked = !this.allChecked
                this.items.forEach((i: CartItem) => i.isChecked = this.allChecked)
                this.items = [...this.items]
                await CartService.updateAllChecked(this.allChecked ? 1 : 0)
              })
            Text(this.t('全选', 'All')).fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme))
          }
          Blank()
          Column() {
            Text(`${this.t('合计', 'Total')}: ¥${(this.calcTotal() / 100).toFixed(2)}`)
              .fontSize(this.fs(16)).fontWeight(FontWeight.Bold).fontColor(Theme.primary(this.theme))
            Text(this.t('不含运费', 'Excl. shipping')).fontSize(this.fs(10)).fontColor(Theme.textHint(this.theme))
          }
          .alignItems(HorizontalAlign.End).margin({ right: 12 })

          Button(`${this.t('结算', 'Checkout')}(${this.calcCheckedCount()})`)
            .fontSize(this.fs(14))
            .backgroundColor(this.calcCheckedCount() > 0 ? Theme.primary(this.theme) : Theme.textHint(this.theme))
            .borderRadius(20).height(36).width(100)
            .enabled(this.calcCheckedCount() > 0)
            .onClick(() => {
              router.pushUrl({ url: Constants.PAGE_ORDER_CONFIRM })
            })
        }
        .width('100%').height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Theme.card(this.theme))
      }
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }
}
