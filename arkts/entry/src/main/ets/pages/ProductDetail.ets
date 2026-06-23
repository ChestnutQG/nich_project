// 商品详情页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Utils } from '../common/Utils'
import { Product, Sku, CraftStep } from '../model/Product'
import { ProductService } from '../service/ProductService'
import { CartService, CartItem } from '../service/CartService'
import { NavBar } from '../components/NavBar'
import { PriceText } from '../components/PriceText'
import { RatingStars } from '../components/RatingStars'
import { SkuSelector } from '../components/SkuSelector'

@Entry
@Component
struct ProductDetail {
  @State product: Product | undefined = undefined
  @State selectedSku: Sku | undefined = undefined
  @State showSkuSelector: boolean = false
  @State loading: boolean = true
  private productId: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    if (params && params['productId']) {
      this.productId = params['productId']
      this.loadProduct()
    }
  }

  async loadProduct(): Promise<void> {
    const resp = await ProductService.fetchProductDetail(this.productId)
    if (resp.code === 0 && resp.data) {
      this.product = resp.data
      this.selectedSku = resp.data.skus[0]
    }
    this.loading = false
  }

  build() {
    Column() {
      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Colors.PRIMARY)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (!this.product) {
        Column() {
          Text('商品不存在').fontSize(16).fontColor(Colors.TEXT_HINT)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 可滚动内容
        Scroll() {
          Column() {
            // 图片轮播
            Swiper() {
              ForEach(this.product!.images, (img: string) => {
                Image(img)
                  .width('100%')
                  .height(375)
                  .objectFit(ImageFit.Cover)
              })
            }
            .width('100%')
            .height(375)
            .indicatorStyle({ selectedColor: Colors.PRIMARY })

            // 商品基本信息
            Column() {
              // 价格行
              Row() {
                if (this.selectedSku) {
                  PriceText({ price: this.selectedSku.price, originalPrice: this.product!.originalPrice, textSize: 22 })
                }
                Blank()
                Text(`已售${Utils.formatCount(this.product!.sales)}`)
                  .fontSize(12)
                  .fontColor(Colors.TEXT_SECONDARY)
              }
              .width('100%')

              // 名称
              Text(this.product!.name)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .width('100%')
                .margin({ top: 10 })

              // 描述
              Text(this.product!.description)
                .fontSize(13)
                .fontColor(Colors.TEXT_SECONDARY)
                .width('100%')
                .margin({ top: 6 })
                .lineHeight(20)

              // 标签
              Row() {
                ForEach(this.product!.tags, (tag: string) => {
                  Text(tag)
                    .fontSize(10)
                    .fontColor(Colors.PRIMARY)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(4)
                    .border({ width: 1, color: Colors.PRIMARY_LIGHT })
                    .margin({ right: 6 })
                })
              }
              .width('100%')
              .margin({ top: 10 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Colors.BG_WHITE)

            // 匠人信息卡片
            this.ArtisanInfoCard()

            // 规格选择区
            Column() {
              Row() {
                Text('已选规格')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_SECONDARY)
                Text(this.selectedSku?.name ?? '请选择')
                  .fontSize(14)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .margin({ left: 8 })
                Blank()
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(14)
                  .height(14)
                  .fillColor(Colors.TEXT_HINT)
              }
              .width('100%')
              .padding(12)
              .onClick(() => { this.showSkuSelector = !this.showSkuSelector })
            }
            .width('100%')
            .margin({ top: 10 })
            .backgroundColor(Colors.BG_WHITE)

            // SKU 选择器
            if (this.showSkuSelector) {
              SkuSelector({
                skus: this.product!.skus,
                selectedSkuId: this.selectedSku?.id ?? '',
                onSelect: (sku: Sku) => {
                  this.selectedSku = sku
                }
              })
            }

            // 文化故事
            Column() {
              Row() {
                Text('文化故事')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 })

              Text(this.product!.story)
                .fontSize(13)
                .fontColor(Colors.TEXT_SECONDARY)
                .lineHeight(22)
                .width('100%')
                .padding({ left: 16, right: 16, top: 8, bottom: 16 })
            }
            .width('100%')
            .margin({ top: 10 })
            .backgroundColor(Colors.BG_WHITE)

            // 制作工艺
            if (this.product!.craftProcess.length > 0) {
              Column() {
                Row() {
                  Text('制作工艺')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Colors.TEXT_PRIMARY)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 16 })

                ForEach(this.product!.craftProcess, (step: CraftStep, index: number) => {
                  Row() {
                    Column() {
                      Text(`${index + 1}`)
                        .fontSize(12)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(Color.White)
                    }
                    .width(22)
                    .height(22)
                    .borderRadius(11)
                    .backgroundColor(Colors.PRIMARY)
                    .justifyContent(FlexAlign.Center)

                    Column() {
                      Text(step.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Colors.TEXT_PRIMARY)
                      Text(step.description)
                        .fontSize(12)
                        .fontColor(Colors.TEXT_SECONDARY)
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .margin({ left: 10 })
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                })

                Row().height(16)
              }
              .width('100%')
              .margin({ top: 10 })
              .backgroundColor(Colors.BG_WHITE)
            }

            // 评分
            Column() {
              Row() {
                RatingStars({ rating: this.product!.rating, starSize: 16 })
                Text(`${this.product!.rating.toFixed(1)}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.GOLD)
                  .margin({ left: 6 })
              }
              .width('100%')
              .padding(16)
            }
            .width('100%')
            .margin({ top: 10 })
            .backgroundColor(Colors.BG_WHITE)

            Row().height(80) // 底部操作栏占位
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Colors.BG_PAPER)
        .scrollBar(BarState.Off)

        // 底部操作栏
        this.BottomBar()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ArtisanInfoCard() {
    Row() {
      // 这里简化，实际从 Artisan 数据中获取
      Image('https://picsum.photos/seed/art01/48/48')
        .width(40)
        .height(40)
        .borderRadius(20)
        .objectFit(ImageFit.Cover)
        .border({ width: 1, color: Colors.GOLD })

      Column() {
        Text(this.product!.artisanName)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.TEXT_PRIMARY)
        Text('非遗传承人')
          .fontSize(11)
          .fontColor(Colors.GOLD)
          .margin({ top: 2 })
      }
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('查看匠人 >')
        .fontSize(12)
        .fontColor(Colors.PRIMARY)
    }
    .width('100%')
    .padding(12)
    .borderRadius(8)
    .backgroundColor(Colors.BG_WHITE)
    .margin({ left: 16, right: 16, top: 10 })
  }

  @Builder
  BottomBar() {
    Row() {
      // 收藏
      Column() {
        Text(this.product!.isCollect ? '❤️' : '🤍')
          .fontSize(22)
        Text('收藏')
          .fontSize(10)
          .fontColor(Colors.TEXT_SECONDARY)
      }
      .width(48)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        if (this.product) {
          this.product.isCollect = !this.product.isCollect
        }
      })

      // 客服
      Column() {
        Text('💬')
          .fontSize(22)
        Text('客服')
          .fontSize(10)
          .fontColor(Colors.TEXT_SECONDARY)
      }
      .width(48)
      .alignItems(HorizontalAlign.Center)

      // 加入购物车
      Button('加入购物车')
        .fontSize(14)
        .backgroundColor(Colors.GOLD)
        .borderRadius(20)
        .height(40)
        .layoutWeight(1)
        .margin({ left: 12, right: 8 })
        .onClick(() => {
          // 添加购物车逻辑
          const cartItem: CartItem = {
            productId: this.product!.id,
            productName: this.product!.name,
            productImage: this.product!.images[0],
            artisanName: this.product!.artisanName,
            skuId: this.selectedSku!.id,
            skuName: this.selectedSku!.name,
            price: this.selectedSku!.price,
            quantity: 1,
            checked: true
          }
          CartService.addToCart(cartItem)
          // 提示
        })

      // 立即购买
      Button('立即购买')
        .fontSize(14)
        .backgroundColor(Colors.PRIMARY)
        .borderRadius(20)
        .height(40)
        .layoutWeight(1)
        .onClick(() => {
          router.pushUrl({ url: Constants.PAGE_ORDER_CONFIRM, params: { productId: this.product!.id, skuId: this.selectedSku!.id } })
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Colors.BG_WHITE)
  }
}
