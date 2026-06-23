// 星级评分组件
import { Colors } from '../common/Colors'

@Component
export struct RatingStars {
  @Prop rating: number = 5     // 评分 1-5
  @Prop starSize: number = 14

  build() {
    Row() {
      ForEach([1, 2, 3, 4, 5], (i: number) => {
        Text(i <= this.rating ? '★' : '☆')
          .fontSize(this.starSize)
          .fontColor(i <= this.rating ? Colors.GOLD : Colors.TEXT_HINT)
          .margin({ right: i < 5 ? 2 : 0 })
      })
    }
  }
}
