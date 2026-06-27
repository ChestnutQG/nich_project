// 我的关注页 — 展示用户关注的匠人
import { router, promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Artisan } from '../model/Artisan'
import { FollowService } from '../service/FollowService'
import { NavBar } from '../components/NavBar'

@Entry
@Component
struct FollowList {
  @State artisans: Artisan[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    this.loadFollows()
  }

  onPageShow(): void {
    // 从匠人详情取消关注后返回时刷新
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
      promptAction.showToast({ message: '已取消关注' })
      this.loadFollows()
    } else {
      promptAction.showToast({ message: resp.message || '操作失败' })
    }
  }

  build() {
    Column() {
      NavBar({ title: '我的关注', showBack: true })

      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Colors.PRIMARY)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.artisans.length === 0) {
        Column() {
          Text('🧑‍🎨').fontSize(48).opacity(0.6)
          Text('还没有关注的匠人').fontSize(14).fontColor(Colors.TEXT_HINT).margin({ top: 8 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Colors.BG_PAPER)
      } else {
        Scroll() {
          Column() {
            ForEach(this.artisans, (artisan: Artisan) => {
              Row() {
                Image(artisan.avatar)
                  .width(56).height(56).borderRadius(28).objectFit(ImageFit.Cover)
                  .border({ width: 2, color: artisan.level >= 3 ? Colors.GOLD : Colors.DIVIDER })

                Column() {
                  Row() {
                    Text(artisan.name)
                      .fontSize(15).fontWeight(FontWeight.Medium).fontColor(Colors.TEXT_PRIMARY)
                    Text(artisan.title)
                      .fontSize(10).fontColor(artisan.level >= 3 ? Colors.GOLD : Colors.PRIMARY)
                      .margin({ left: 8 })
                  }
                  Text(`${artisan.craftType} · ${artisan.city}`)
                    .fontSize(12).fontColor(Colors.TEXT_SECONDARY).margin({ top: 4 })
                  Text(`${artisan.worksCount}作品 · ${artisan.followersCount}关注`)
                    .fontSize(11).fontColor(Colors.TEXT_HINT).margin({ top: 2 })
                }
                .layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)

                Button('已关注')
                  .fontSize(12)
                  .backgroundColor(Colors.DIVIDER).fontColor(Colors.TEXT_HINT)
                  .borderRadius(14).height(28).padding({ left: 12, right: 12 })
                  .onClick(() => { this.unfollow(artisan) })
              }
              .width('100%').padding(14).borderRadius(8)
              .backgroundColor(Colors.BG_WHITE)
              .margin({ left: 16, right: 16, top: 8 })
              .onClick(() => {
                router.pushUrl({ url: Constants.PAGE_ARTISAN_DETAIL, params: { artisanId: artisan.id } })
              })
            })
          }
          .padding({ bottom: 16 })
        }
        .width('100%').layoutWeight(1)
        .backgroundColor(Colors.BG_PAPER).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%')
  }
}
