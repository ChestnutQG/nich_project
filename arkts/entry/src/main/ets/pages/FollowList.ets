// 我的关注页 — 展示用户关注的匠人
import { router, promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Artisan } from '../model/Artisan'
import { FollowService } from '../service/FollowService'
import { NavBar } from '../components/NavBar'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct FollowList {
  @State artisans: Artisan[] = []
  @State loading: boolean = true

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  aboutToAppear(): void {
    this.loadFollows()
  }

  onPageShow(): void {
    this.loadFollows()
  }

  async loadFollows(): Promise<void> {
    this.loading = true
    const resp = await FollowService.fetchMyFollows()
    if (resp.code === 0) {
      this.artisans = resp.data
    }
    this.loading = false
  }

  async unfollow(artisan: Artisan): Promise<void> {
    const resp = await FollowService.unfollow(artisan.id)
    if (resp.code === 0) {
      promptAction.showToast({ message: this.t('已取消关注', 'Unfollowed') })
      this.loadFollows()
    } else {
      promptAction.showToast({ message: resp.message || this.t('操作失败', 'Failed') })
    }
  }

  build() {
    Column() {
      NavBar({ title: this.t('我的关注', 'Following'), showBack: true })

      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Theme.primary(this.theme))
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else if (this.artisans.length === 0) {
        Column() {
          Text('🧑‍🎨').fontSize(this.fs(48)).opacity(0.6)
          Text(this.t('还没有关注的匠人', 'No artisans followed'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textHint(this.theme))
            .margin({ top: 8 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else {
        Scroll() {
          Column() {
            ForEach(this.artisans, (artisan: Artisan) => {
              Row() {
                Image(artisan.avatar)
                  .width(56).height(56).borderRadius(28).objectFit(ImageFit.Cover)
                  .border({ width: 2, color: artisan.level >= 3 ? Theme.gold(this.theme) : Theme.divider(this.theme) })

                Column() {
                  Row() {
                    Text(artisan.name)
                      .fontSize(this.fs(15)).fontWeight(FontWeight.Medium).fontColor(Theme.textPrimary(this.theme))
                    Text(artisan.title)
                      .fontSize(this.fs(10)).fontColor(artisan.level >= 3 ? Theme.gold(this.theme) : Theme.primary(this.theme))
                      .margin({ left: 8 })
                  }
                  Text(`${artisan.craftType} · ${artisan.city}`)
                    .fontSize(this.fs(12)).fontColor(Theme.textSecondary(this.theme)).margin({ top: 4 })
                  Text(`${artisan.worksCount}${this.t('作品', ' works')} · ${artisan.followersCount}${this.t('关注', ' followers')}`)
                    .fontSize(this.fs(11)).fontColor(Theme.textHint(this.theme)).margin({ top: 2 })
                }
                .layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)

                Button(this.t('已关注', 'Following'))
                  .fontSize(this.fs(12))
                  .backgroundColor(Theme.divider(this.theme)).fontColor(Theme.textHint(this.theme))
                  .borderRadius(14).height(28).padding({ left: 12, right: 12 })
                  .onClick(() => { this.unfollow(artisan) })
              }
              .width('100%').padding(14).borderRadius(8)
              .backgroundColor(Theme.card(this.theme))
              .margin({ left: 16, right: 16, top: 8 })
              .onClick(() => {
                router.pushUrl({ url: Constants.PAGE_ARTISAN_DETAIL, params: { artisanId: artisan.id } })
              })
            })
          }
          .padding({ bottom: 16 })
        }
        .width('100%').layoutWeight(1)
        .backgroundColor(Theme.bg(this.theme)).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }
}
