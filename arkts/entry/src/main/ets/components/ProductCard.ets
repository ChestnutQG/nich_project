// 商品卡片组件 — 国风版
import { Product } from '../model/Product'
import { Colors } from '../common/Colors'
import { Utils } from '../common/Utils'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Component
export struct ProductCard {
  @Prop product: Product
  @Prop hideCommerceInfo: boolean = false
  onItemClick?: (product: Product) => void

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  build() {
    Column() {
      // 商品图片
      Image(this.product.images.length > 0 ? this.product.images[0] : '')
        .width('100%')
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 4, topRight: 4 })

      // 信息区
      Column() {
        // 商品名称
        Text(this.product.name)
          .fontSize(this.fs(14))
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.textPrimary(this.theme))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 匠人名称
        Text(this.product.artisanName)
          .fontSize(this.fs(11))
          .fontColor(Theme.textSecondary(this.theme))
          .margin({ top: 4 })

        if (!this.hideCommerceInfo) {
          // 价格行
          Row() {
            Text(Utils.formatPrice(this.product.price))
              .fontSize(this.fs(16))
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.primary(this.theme))

            if (this.product.originalPrice > this.product.price) {
              Text(Utils.formatPrice(this.product.originalPrice))
                .fontSize(this.fs(11))
                .fontColor(Theme.textHint(this.theme))
                .decoration({ type: TextDecorationType.LineThrough })
                .margin({ left: 6 })
            }

            Blank()

            Text(`已售${Utils.formatCount(this.product.sales)}`)
              .fontSize(this.fs(10))
              .fontColor(Theme.textHint(this.theme))
          }
          .width('100%')
          .margin({ top: 6 })
        }
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 10 })
    }
    .width('100%')
    .borderRadius(4)
    .backgroundColor(Theme.card(this.theme))
    .border({ width: 0.5, color: Theme.divider(this.theme) })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.product)
      }
    })
  }
}
