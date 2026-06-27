// 匠人列表页
import { router, promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Artisan } from '../model/Artisan'
import { ArtisanService } from '../service/ArtisanService'
import { FollowService } from '../service/FollowService'
import { NavBar } from '../components/NavBar'

@Entry
@Component
struct ArtisanList {
  @State artisans: Artisan[] = []

  aboutToAppear(): void {
    this.loadArtisans()
  }

  async loadArtisans(): Promise<void> {
    const resp = await ArtisanService.fetchList()
    if (resp.code === 0) {
      this.artisans = resp.data
    } else {
      promptAction.showToast({ message: resp.message || '加载失败' })
    }
  }

  // 关注 / 取消关注
  async toggleFollow(artisan: Artisan): Promise<void> {
    const willFollow = !artisan.isFollowed
    const resp = willFollow
      ? await FollowService.follow(artisan.id)
      : await FollowService.unfollow(artisan.id)
    if (resp.code === 0) {
      artisan.isFollowed = willFollow
      artisan.followersCount += willFollow ? 1 : -1
      this.artisans = [...this.artisans]   // 触发列表刷新
    } else {
      promptAction.showToast({ message: resp.message || '操作失败' })
    }
  }

  build() {
    Column() {
      NavBar({ title: '匠人传承', showBack: true })

      Scroll() {
        Column() {
          ForEach(this.artisans, (artisan: Artisan) => {
            Row() {
              Image(artisan.avatar)
                .width(56)
                .height(56)
                .borderRadius(28)
                .objectFit(ImageFit.Cover)
                .border({ width: 2, color: artisan.level >= 3 ? Colors.GOLD : Colors.DIVIDER })

              Column() {
                Row() {
                  Text(artisan.name)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Colors.TEXT_PRIMARY)
                  Text(artisan.title)
                    .fontSize(10)
                    .fontColor(artisan.level >= 3 ? Colors.GOLD : Colors.PRIMARY)
                    .margin({ left: 8 })
                }

                Text(`${artisan.craftType} · ${artisan.city}`)
                  .fontSize(12)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .margin({ top: 4 })

                Text(`${artisan.worksCount}作品 · ${artisan.followersCount}关注`)
                  .fontSize(11)
                  .fontColor(Colors.TEXT_HINT)
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)

              Button(artisan.isFollowed ? '已关注' : '+ 关注')
                .fontSize(12)
                .backgroundColor(artisan.isFollowed ? Colors.DIVIDER : Colors.PRIMARY_BG)
                .fontColor(artisan.isFollowed ? Colors.TEXT_HINT : Colors.PRIMARY)
                .borderRadius(14)
                .height(28)
                .padding({ left: 12, right: 12 })
                .onClick(() => { this.toggleFollow(artisan) })
            }
            .width('100%')
            .padding(14)
            .borderRadius(8)
            .backgroundColor(Colors.BG_WHITE)
            .margin({ left: 16, right: 16, top: 8 })
            .onClick(() => {
              router.pushUrl({ url: Constants.PAGE_ARTISAN_DETAIL, params: { artisanId: artisan.id } })
            })
          })
        }
        .padding({ bottom: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Colors.BG_PAPER)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
