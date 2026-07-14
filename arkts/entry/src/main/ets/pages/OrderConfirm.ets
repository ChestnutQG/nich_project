// 确认订单页
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { NavBar } from '../components/NavBar'
import { PriceText } from '../components/PriceText'
import { Order, OrderStatus, OrderItem } from '../model/Order'
import { Address } from '../model/Address'
import { Product } from '../model/Product'
import { ProductService } from '../service/ProductService'
import { OrderService } from '../service/OrderService'
import { CartService } from '../service/CartService'
import { AddressService } from '../service/AddressService'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct OrderConfirm {
  @State address: Address | null = null
  @State submitting: boolean = false
  @State loading: boolean = true
  @State cartItems: OrderItem[] = []

  private productId: string = ''
  private skuId: string = ''
  private cartItemIds: string[] = []

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  private calcTotalAmount(): number {
    let sum = 0
    this.cartItems.forEach((item) => { sum += item.price * item.quantity })
    return sum
  }

  private calcDiscountAmount(): number {
    return 0
  }

  private calcPayAmount(): number {
    return this.calcTotalAmount() - this.calcDiscountAmount()
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    if (params && params['productId']) {
      this.productId = params['productId']
      this.skuId = params['skuId'] || ''
      this.loadProductData()
    } else {
      this.loadFromCart()
    }
  }

  onPageShow(): void {
    const picked = AppStorage.get<string>('orderSelectedAddressId')
    if (picked) {
      AppStorage.delete('orderSelectedAddressId')
      this.loadAddress(picked)
    } else if (!this.address) {
      this.loadAddress()
    }
  }

  async loadAddress(preferId?: string): Promise<void> {
    const resp = await AddressService.fetchList()
    if (resp.code === 0 && resp.data.length > 0) {
      if (preferId) {
        const picked = resp.data.find((a: Address) => a.id === preferId)
        const def = resp.data.find((a: Address) => a.isDefault)
        this.address = picked ? picked : (def ? def : resp.data[0])
      } else {
        const def = resp.data.find((a: Address) => a.isDefault)
        this.address = def ? def : resp.data[0]
      }
    } else {
      this.address = null
    }
  }

  async loadProductData(): Promise<void> {
    const resp = await ProductService.fetchProductDetail(this.productId)
    if (resp.code === 0 && resp.data) {
      const p = resp.data
      let selectedSku = p.skus.length > 0 ? p.skus[0] : undefined
      if (this.skuId) {
        const found = p.skus.find((sku) => sku.id === this.skuId)
        if (found) selectedSku = found
      }
      this.cartItems = [
        {
          productId: p.id,
          productName: p.name,
          productImage: p.images.length > 0 ? p.images[0] : '',
          skuId: selectedSku ? selectedSku.id : '',
          skuName: selectedSku ? selectedSku.name : '',
          price: selectedSku ? selectedSku.price : p.price,
          quantity: 1
        }
      ]
    }
    this.loading = false
  }

  async loadFromCart(): Promise<void> {
    const resp = await CartService.fetchCartList()
    if (resp.code === 0 && resp.data) {
      const items: OrderItem[] = []
      const ids: string[] = []
      for (let i = 0; i < resp.data.length; i++) {
        const ci = resp.data[i]
        if (ci.isChecked) {
          const item: OrderItem = {
            productId: ci.productId,
            productName: ci.productName,
            productImage: ci.productImage,
            skuId: ci.skuId,
            skuName: ci.skuName,
            price: ci.price,
            quantity: ci.quantity
          }
          items.push(item)
          ids.push(ci.id)
        }
      }
      this.cartItems = items
      this.cartItemIds = ids
    }
    this.loading = false
  }

  build() {
    Column() {
      NavBar({ title: this.t('确认订单', 'Confirm Order'), showBack: true })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Theme.primary(this.theme))
          Text(this.t('加载中...', 'Loading...')).fontSize(this.fs(14)).fontColor(Theme.textHint(this.theme)).margin({ left: 8 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else {
        Scroll() {
          Column() {
            // 收货地址
            Row() {
              Text('📍')
                .fontSize(this.fs(22))
                .margin({ right: 10 })

              if (this.address) {
                Column() {
                  Row() {
                    Text(this.address!.name)
                      .fontSize(this.fs(15))
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.textPrimary(this.theme))
                    Text(this.address!.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                      .fontSize(this.fs(13))
                      .fontColor(Theme.textSecondary(this.theme))
                      .margin({ left: 16 })
                  }
                  Text(`${this.address!.province}${this.address!.city}${this.address!.district} ${this.address!.detail}`)
                    .fontSize(this.fs(13))
                    .fontColor(Theme.textSecondary(this.theme))
                    .margin({ top: 4 })
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              } else {
                Text(this.t('请添加收货地址', 'Add shipping address'))
                  .fontSize(this.fs(15))
                  .fontColor(Theme.textHint(this.theme))
                  .layoutWeight(1)
              }

              Image($r('sys.media.ohos_ic_public_arrow_right'))
                .width(14)
                .height(14)
                .fillColor(Theme.textHint(this.theme))
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card(this.theme))
            .onClick(() => {
              router.pushUrl({ url: Constants.PAGE_ADDRESS_LIST, params: { mode: 'select' } })
            })

            // 商品信息
            Column() {
              ForEach(this.cartItems, (item: OrderItem) => {
                Row() {
                  Image(item.productImage)
                    .width(72)
                    .height(72)
                    .borderRadius(6)
                    .objectFit(ImageFit.Cover)

                  Column() {
                    Text(item.productName)
                      .fontSize(this.fs(14))
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
                    PriceText({ price: item.price, textSize: 15 })
                    Text(`x${item.quantity}`)
                      .fontSize(this.fs(11))
                      .fontColor(Theme.textHint(this.theme))
                      .margin({ top: 4 })
                  }
                }
                .width('100%')
                .padding({ top: 6, bottom: 6 })
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card(this.theme))
            .margin({ top: 8 })

            // 金额汇总
            Column() {
              this.AmountRow(this.t('商品总额', 'Subtotal'), this.calcTotalAmount())
              this.AmountRow(this.t('运费', 'Shipping'), 0)
              this.AmountRow(this.t('优惠', 'Discount'), -this.calcDiscountAmount())
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card(this.theme))
            .margin({ top: 8 })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Theme.bg(this.theme))
        .scrollBar(BarState.Off)

        // 底部提交栏
        Row() {
          Text(this.t('实付: ', 'Pay: '))
            .fontSize(this.fs(14))
            .fontColor(Theme.textPrimary(this.theme))
          Text(`¥${(this.calcPayAmount() / 100).toFixed(2)}`)
            .fontSize(this.fs(20))
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.primary(this.theme))

          Blank()

          Button(this.submitting ? this.t('提交中...', 'Submitting...') : this.t('提交订单', 'Place Order'))
            .fontSize(this.fs(15))
            .backgroundColor(this.submitting ? Theme.textHint(this.theme) : Theme.primary(this.theme))
            .borderRadius(20)
            .height(40)
            .width(120)
            .onClick(() => {
              if (!this.submitting) { this.handleSubmit() }
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Theme.card(this.theme))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }

  @Builder
  AmountRow(label: string, amount: number) {
    Row() {
      Text(label)
        .fontSize(this.fs(14))
        .fontColor(Theme.textSecondary(this.theme))
      Blank()
      Text(`${amount >= 0 ? '' : '-'}¥${(Math.abs(amount) / 100).toFixed(2)}`)
        .fontSize(this.fs(14))
        .fontColor(Theme.textPrimary(this.theme))
    }
    .width('100%')
    .margin({ top: 6 })
  }

  private async handleSubmit(): Promise<void> {
    if (!this.address) {
      promptAction.showToast({ message: this.t('请先添加收货地址', 'Please add a shipping address') })
      return
    }
    if (this.cartItems.length === 0) {
      promptAction.showToast({ message: this.t('没有可下单的商品', 'No items to order') })
      return
    }
    const addr: Address = this.address!
    this.submitting = true

    const order: Order = {
      id: '',
      orderNo: '',
      status: OrderStatus.PENDING_PAY,
      items: this.cartItems,
      totalAmount: this.calcTotalAmount(),
      discountAmount: this.calcDiscountAmount(),
      freight: 0,
      payAmount: this.calcPayAmount(),
      address: addr,
      createTime: Date.now()
    }

    const resp = await OrderService.createOrder(order)
    this.submitting = false

    if (resp.code === 0) {
      for (const id of this.cartItemIds) {
        await CartService.removeItem(id)
      }
      this.cartItemIds = []
      promptAction.showToast({ message: this.t('下单成功', 'Order placed') })
      router.pushUrl({ url: Constants.PAGE_ORDER_LIST })
    } else {
      promptAction.showToast({ message: resp.message || this.t('下单失败', 'Failed') })
    }
  }
}
