// 商品卡片组件
import { Product } from '../model/Product'
import { Colors } from '../common/Colors'
import { Utils } from '../common/Utils'

@Component
export struct ProductCard {
  @Prop product: Product
  onItemClick?: (product: Product) => void

  build() {
    Column() {
      // 商品图片
      Image(this.product.images[0])
        .width('100%')
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 8, topRight: 8 })

      // 信息区
      Column() {
        // 商品名称
        Text(this.product.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.TEXT_PRIMARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 匠人名称
        Text(this.product.artisanName)
          .fontSize(11)
          .fontColor(Colors.TEXT_SECONDARY)
          .margin({ top: 4 })

        // 价格行
        Row() {
          Text(Utils.formatPrice(this.product.price))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.PRIMARY)

          if (this.product.originalPrice > this.product.price) {
            Text(Utils.formatPrice(this.product.originalPrice))
              .fontSize(11)
              .fontColor(Colors.TEXT_HINT)
              .decoration({ type: TextDecorationType.LineThrough })
              .margin({ left: 6 })
          }

          Blank()

          Text(`已售${Utils.formatCount(this.product.sales)}`)
            .fontSize(10)
            .fontColor(Colors.TEXT_HINT)
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 10 })
    }
    .width('100%')
    .borderRadius(8)
    .backgroundColor(Colors.BG_CARD)
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.product)
      }
    })
  }
}
