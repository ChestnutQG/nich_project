// 加载更多提示
import { Colors } from '../common/Colors'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Component
export struct LoadingMore {
  @Prop hasMore: boolean = true
  @Prop loading: boolean = false

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  build() {
    Row() {
      if (this.loading) {
        LoadingProgress()
          .width(16)
          .height(16)
          .color(Theme.primary(this.theme))
        Text(this.t('加载中...', 'Loading...'))
          .fontSize(this.fs(12))
          .fontColor(Theme.textSecondary(this.theme))
          .margin({ left: 6 })
      } else if (this.hasMore) {
        Text(this.t('上拉加载更多', 'Pull up to load more'))
          .fontSize(this.fs(12))
          .fontColor(Theme.textHint(this.theme))
      } else {
        Text(this.t('— 已经到底了 —', '— No more —'))
          .fontSize(this.fs(12))
          .fontColor(Theme.textHint(this.theme))
      }
    }
    .width('100%')
    .height(44)
    .justifyContent(FlexAlign.Center)
  }
}
