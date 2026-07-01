// SKU 规格选择器 — 国风版
import { Sku } from '../model/Product'
import { Colors } from '../common/Colors'
import { Utils } from '../common/Utils'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Component
export struct SkuSelector {
  @Prop skus: Sku[] = []
  @Prop selectedSkuId: string = ''
  onSelect?: (sku: Sku) => void

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  build() {
    Column() {
      Text(this.t('选择规格', 'Select Spec'))
        .fontSize(this.fs(16))
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.textPrimary(this.theme))
        .width('100%')
        .padding({ left: 20, top: 20, bottom: 12 })

      Scroll() {
        Row() {
          ForEach(this.skus, (sku: Sku) => {
            Column() {
              Image(sku.image)
                .width(60)
                .height(60)
                .objectFit(ImageFit.Cover)
                .borderRadius(3)

              Text(sku.name)
                .fontSize(this.fs(12))
                .fontColor(Theme.textPrimary(this.theme))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width(80)
                .textAlign(TextAlign.Center)
                .margin({ top: 4 })

              Text(Utils.formatPrice(sku.price))
                .fontSize(this.fs(13))
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.primary(this.theme))
                .margin({ top: 2 })

              if (sku.stock === 0) {
                Text(this.t('已售罄', 'Sold Out'))
                  .fontSize(this.fs(10))
                  .fontColor(Theme.textHint(this.theme))
              }
            }
            .width(100)
            .padding(8)
            .borderRadius(4)
            .border({
              width: sku.id === this.selectedSkuId ? 2 : 1,
              color: sku.id === this.selectedSkuId ? Theme.primary(this.theme) : Theme.divider(this.theme)
            })
            .backgroundColor(sku.id === this.selectedSkuId ? Theme.primaryBg(this.theme) : Theme.card(this.theme))
            .margin({ right: 12 })
            .opacity(sku.stock === 0 ? 0.4 : 1)
            .onClick(() => {
              if (sku.stock > 0 && this.onSelect) {
                this.onSelect(sku)
              }
            })
          })
        }
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .backgroundColor(Theme.card(this.theme))
  }
}
