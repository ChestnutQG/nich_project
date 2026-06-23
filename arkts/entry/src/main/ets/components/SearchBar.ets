// 搜索栏组件
import { Colors } from '../common/Colors'

@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索非遗好物...'
  onSearch?: (keyword: string) => void
  onTap?: () => void

  build() {
    Row() {
      Text('🔍')
        .fontSize(16)
        .margin({ right: 8 })

      Text(this.placeholder)
        .fontSize(14)
        .fontColor(Colors.TEXT_HINT)
        .layoutWeight(1)
    }
    .width('100%')
    .height(40)
    .borderRadius(20)
    .backgroundColor(Colors.BG_WHITE)
    .padding({ left: 16, right: 16 })
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .onClick(() => {
      if (this.onTap) {
        this.onTap()
      }
    })
  }
}
