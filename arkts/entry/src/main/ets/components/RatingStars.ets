// 星级评分组件 — 国风版
import { Colors } from '../common/Colors'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Component
export struct RatingStars {
  @Prop rating: number = 5     // 评分 1-5
  @Prop starSize: number = 14

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  build() {
    Row() {
      ForEach([1, 2, 3, 4, 5], (i: number) => {
        Text(i <= this.rating ? '★' : '☆')
          .fontSize(this.starSize)
          .fontColor(i <= this.rating ? Theme.gold(this.theme) : Theme.divider(this.theme))
          .margin({ right: i < 5 ? 2 : 0 })
      })
    }
  }
}
