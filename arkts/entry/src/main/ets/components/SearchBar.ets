// 搜索栏组件
import { Colors } from '../common/Colors'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索非遗好物...'
  onSearch?: (keyword: string) => void
  onTap?: () => void

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  build() {
    Row() {
      Text('🔍')
        .fontSize(this.fs(16))
        .margin({ right: 8 })

      Text(this.placeholder)
        .fontSize(this.fs(14))
        .fontColor(Theme.textHint(this.theme))
        .layoutWeight(1)
    }
    .width('100%')
    .height(40)
    .borderRadius(20)
    .backgroundColor(Theme.card(this.theme))
    .padding({ left: 16, right: 16 })
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .onClick(() => {
      if (this.onTap) {
        this.onTap()
      }
    })
  }
}
