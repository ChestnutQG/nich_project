// 匠人卡片组件 — 国风版
import { Artisan } from '../model/Artisan'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Utils } from '../common/Utils'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Component
export struct ArtisanCard {
  @Prop artisan: Artisan
  onItemClick?: (artisan: Artisan) => void

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  build() {
    Column() {
      // 头像
      Image(this.artisan.avatar)
        .width(64)
        .height(64)
        .borderRadius(32)
        .objectFit(ImageFit.Cover)
        .border({ width: 2.5, color: Theme.gold(this.theme) })

      // 姓名
      Text(this.artisan.name)
        .fontSize(this.fs(14))
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.textPrimary(this.theme))
        .margin({ top: 8 })
        .maxLines(1)

      // 头衔 — 印章风
      Text(this.artisan.title)
        .fontSize(this.fs(9))
        .fontColor(this.artisan.level >= 3 ? Theme.WHITE : Theme.textSecondary(this.theme))
        .backgroundColor(this.artisan.level >= 3 ? Theme.gold(this.theme) : 'transparent')
        .borderRadius(3)
        .padding(this.artisan.level >= 3
          ? { left: 6, right: 6, top: 2, bottom: 2 }
          : { left: 0, right: 0, top: 0, bottom: 0 })
        .margin({ top: 2 })
        .maxLines(1)

      // 关注数
      Text(`${Utils.formatCount(this.artisan.followersCount)} 人关注`)
        .fontSize(this.fs(10))
        .fontColor(Theme.textHint(this.theme))
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .width(100)
    .padding({ top: 12, bottom: 12, left: 6, right: 6 })
    .borderRadius(4)
    .backgroundColor(Theme.card(this.theme))
    .border({ width: 0.5, color: Theme.divider(this.theme) })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.artisan)
      }
    })
  }
}
