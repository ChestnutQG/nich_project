// 加载更多提示
import { Colors } from '../common/Colors'

@Component
export struct LoadingMore {
  @Prop hasMore: boolean = true
  @Prop loading: boolean = false

  build() {
    Row() {
      if (this.loading) {
        LoadingProgress()
          .width(16)
          .height(16)
          .color(Colors.PRIMARY)
        Text('加载中...')
          .fontSize(12)
          .fontColor(Colors.TEXT_SECONDARY)
          .margin({ left: 6 })
      } else if (this.hasMore) {
        Text('上拉加载更多')
          .fontSize(12)
          .fontColor(Colors.TEXT_HINT)
      } else {
        Text('— 已经到底了 —')
          .fontSize(12)
          .fontColor(Colors.TEXT_HINT)
      }
    }
    .width('100%')
    .height(44)
    .justifyContent(FlexAlign.Center)
  }
}
