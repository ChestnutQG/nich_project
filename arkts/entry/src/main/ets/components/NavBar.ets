// 通用导航栏
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'

@Component
export struct NavBar {
  @Prop title: string = ''
  @Prop showBack: boolean = false
  @Prop bgColor: string = Colors.BG_PAPER
  onBack?: () => void

  build() {
    Row() {
      if (this.showBack) {
        Text('‹')
          .fontSize(28)
          .fontColor(Colors.TEXT_PRIMARY)
          .width(24)
          .height(24)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.onBack) {
              this.onBack()
            } else {
              router.back()
            }
          })
          .margin({ right: 12 })
      }

      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.TEXT_PRIMARY)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      if (this.showBack) {
        Row().width(24).height(24)
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.bgColor)
  }
}
