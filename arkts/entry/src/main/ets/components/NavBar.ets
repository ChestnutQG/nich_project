// 通用导航栏
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Component
export struct NavBar {
  @Prop title: string = ''
  @Prop showBack: boolean = false
  @Prop bgColor: ResourceColor = Colors.BG_PAPER
  onBack?: () => void

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  build() {
    Row() {
      if (this.showBack) {
        Text('‹')
          .fontSize(this.fs(28))
          .fontColor(Theme.textPrimary(this.theme))
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
        .fontSize(this.fs(18))
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.textPrimary(this.theme))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      if (this.showBack) {
        Row().width(24).height(24)
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Theme.bg(this.theme))
  }
}
