// 空状态组件
import { Colors } from '../common/Colors'

@Component
export struct EmptyState {
  @Prop message: string = '暂无内容'
  @Prop iconText: string = '📦'

  build() {
    Column() {
      Text(this.iconText)
        .fontSize(48)
        .opacity(0.6)

      Text(this.message)
        .fontSize(14)
        .fontColor(Colors.TEXT_HINT)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding({ top: 80, bottom: 80 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
