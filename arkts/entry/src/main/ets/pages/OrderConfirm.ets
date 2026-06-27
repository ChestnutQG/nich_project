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

@Entry
@Component
struct OrderConfirm {
  @State address: Address | null = null
  @State submitting: boolean = false
  @State loading: boolean = true
  @State cartItems: OrderItem[] = []

  private productId: string = ''
  private skuId: string = ''

  private calcTotalAmount(): number {
    let sum = 0
    this.cartItems.forEach((item) => { sum += item.price * item.quantity })
    return sum
  }

  private calcDiscountAmount(): number {
    // 暂无优惠券/活动体系，优惠固定为 0
    return 0
  }

  private calcPayAmount(): number {
    return this.calcTotalAmount() - this.calcDiscountAmount()
  }

  aboutToAppear(): void {
    this.loadAddress()
    const params = router.getParams() as Record<string, string>
    if (params && params['productId']) {
      // 从商品详情页过来，按 productId 加载
      this.productId = params['productId']
      this.skuId = params['skuId'] || ''
      this.loadProductData()
    } else {
      // 从购物车过来，直接从 CartService 取选中的商品
      this.loadFromCart()
    }
  }

  onPageShow(): void {
    // 从地址页选择/新增后返回时刷新
    this.loadAddress()
  }

  // 加载默认收货地址（没有默认则取第一条）
  async loadAddress(): Promise<void> {
    const resp = await AddressService.fetchList()
    if (resp.code === 0 && resp.data.length > 0) {
      const def = resp.data.find((a: Address) => a.isDefault)
      this.address = def ? def : resp.data[0]
    } else {
      this.address = null
    }
  }

  async loadProductData(): Promise<void> {
    const resp = await ProductService.fetchProductDetail(this.productId)
    if (resp.code === 0 && resp.data) {
      const p = resp.data
      // 找到选中的 SKU
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

  // 从购物车加载选中的商品
  async loadFromCart(): Promise<void> {
    const resp = await CartService.fetchCartList()
    if (resp.code === 0 && resp.data) {
      const items: OrderItem[] = []
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
        }
      }
      this.cartItems = items
    }
    this.loading = false
  }

  build() {
    Column() {
      NavBar({ title: '确认订单', showBack: true })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Colors.PRIMARY)
          Text('加载中...').fontSize(14).fontColor(Colors.TEXT_HINT).margin({ left: 8 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 收货地址
            Row() {
              Text('📍')
                .fontSize(22)
                .margin({ right: 10 })

              if (this.address) {
                Column() {
                  Row() {
                    Text(this.address!.name)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Colors.TEXT_PRIMARY)
                    Text(this.address!.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                      .fontSize(13)
                      .fontColor(Colors.TEXT_SECONDARY)
                      .margin({ left: 16 })
                  }
                  Text(`${this.address!.province}${this.address!.city}${this.address!.district} ${this.address!.detail}`)
                    .fontSize(13)
                    .fontColor(Colors.TEXT_SECONDARY)
                    .margin({ top: 4 })
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              } else {
                Text('请添加收货地址')
                  .fontSize(15)
                  .fontColor(Colors.TEXT_HINT)
                  .layoutWeight(1)
              }

              Image($r('sys.media.ohos_ic_public_arrow_right'))
                .width(14)
                .height(14)
                .fillColor(Colors.TEXT_HINT)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Colors.BG_WHITE)
            .onClick(() => {
              router.pushUrl({ url: Constants.PAGE_ADDRESS_LIST })
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
                      .fontSize(14)
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
                    PriceText({ price: item.price, textSize: 15 })
                    Text(`x${item.quantity}`)
                      .fontSize(11)
                      .fontColor(Colors.TEXT_HINT)
                      .margin({ top: 4 })
                  }
                }
                .width('100%')
                .padding({ top: 6, bottom: 6 })
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Colors.BG_WHITE)
            .margin({ top: 8 })

            // 金额汇总
            Column() {
              this.AmountRow('商品总额', this.calcTotalAmount())
              this.AmountRow('运费', 0)
              this.AmountRow('优惠', -this.calcDiscountAmount())
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
          Text(`¥${(this.calcPayAmount() / 100).toFixed(2)}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.PRIMARY)

          Blank()

          Button(this.submitting ? '提交中...' : '提交订单')
            .fontSize(15)
            .backgroundColor(this.submitting ? Colors.TEXT_HINT : Colors.PRIMARY)
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
        .backgroundColor(Colors.BG_WHITE)
      }
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
      Text(`${amount >= 0 ? '' : '-'}¥${(Math.abs(amount) / 100).toFixed(2)}`)
        .fontSize(14)
        .fontColor(Colors.TEXT_PRIMARY)
    }
    .width('100%')
    .margin({ top: 6 })
  }

  private async handleSubmit(): Promise<void> {
    if (!this.address) {
      promptAction.showToast({ message: '请先添加收货地址' })
      return
    }
    if (this.cartItems.length === 0) {
      promptAction.showToast({ message: '没有可下单的商品' })
      return
    }
    const addr: Address = this.address!
    this.submitting = true

    // 构建订单
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
      promptAction.showToast({ message: '下单成功' })
      router.pushUrl({ url: Constants.PAGE_ORDER_LIST })
    } else {
      promptAction.showToast({ message: resp.message || '下单失败' })
    }
  }
}
