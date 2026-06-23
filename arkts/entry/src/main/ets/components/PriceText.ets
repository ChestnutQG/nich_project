// 价格展示组件
import { Colors } from '../common/Colors'
import { Utils } from '../common/Utils'

@Component
export struct PriceText {
  @Prop price: number
  @Prop originalPrice: number = 0
  @Prop textSize: number = 14

  build() {
    Row() {
      Text(Utils.formatPrice(this.price))
        .fontSize(this.textSize)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.PRIMARY)

      if (this.originalPrice > 0 && this.originalPrice > this.price) {
        Text(Utils.formatPrice(this.originalPrice))
          .fontSize(this.textSize - 2)
          .fontColor(Colors.TEXT_HINT)
          .decoration({ type: TextDecorationType.LineThrough })
          .margin({ left: 6 })
      }
    }
  }
}
