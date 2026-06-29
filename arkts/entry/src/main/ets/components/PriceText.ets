// 价格展示组件
import { Colors } from '../common/Colors'
import { Utils } from '../common/Utils'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Component
export struct PriceText {
  @Prop price: number
  @Prop originalPrice: number = 0
  @Prop textSize: number = 14

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  build() {
    Row() {
      Text(Utils.formatPrice(this.price))
        .fontSize(this.fs(this.textSize))
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.primary(this.theme))

      if (this.originalPrice > 0 && this.originalPrice > this.price) {
        Text(Utils.formatPrice(this.originalPrice))
          .fontSize(this.fs(this.textSize - 2))
          .fontColor(Theme.textHint(this.theme))
          .decoration({ type: TextDecorationType.LineThrough })
          .margin({ left: 6 })
      }
    }
  }
}
