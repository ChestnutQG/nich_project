// 匠人详情页 — 国风版
import { router, promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Artisan } from '../model/Artisan'
import { Product } from '../model/Product'
import { ArtisanService } from '../service/ArtisanService'
import { FollowService } from '../service/FollowService'
import { AuthService } from '../service/AuthService'
import { NavBar } from '../components/NavBar'
import { ProductCard } from '../components/ProductCard'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct ArtisanDetail {
  @State artisan: Artisan | undefined = undefined
  @State works: Product[] = []
  private artisanId: string = ''

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
    const params = router.getParams() as Record<string, string>
    if (params && params['artisanId']) {
      this.artisanId = params['artisanId']
      this.loadArtisan()
    }
  }

  async loadArtisan(): Promise<void> {
    const detailResp = await ArtisanService.fetchDetail(this.artisanId)
    if (detailResp.code === 0 && detailResp.data) {
      this.artisan = detailResp.data
    } else {
      promptAction.showToast({ message: detailResp.message || this.t('匠人信息加载失败', 'Failed to load artisan') })
      return
    }
    const worksResp = await ArtisanService.fetchProducts(this.artisanId)
    if (worksResp.code === 0) {
      this.works = worksResp.data
    }
  }

  async toggleFollow(): Promise<void> {
    if (!this.artisan) return
    const willFollow = !this.artisan.isFollowed
    const resp = willFollow
      ? await FollowService.follow(this.artisan.id)
      : await FollowService.unfollow(this.artisan.id)
    if (resp.code === 0) {
      this.artisan.isFollowed = willFollow
      this.artisan.followersCount += willFollow ? 1 : -1
      promptAction.showToast({ message: willFollow ? this.t('已关注', 'Followed') : this.t('已取消关注', 'Unfollowed') })
    } else {
      promptAction.showToast({ message: resp.message || this.t('操作失败', 'Failed') })
    }
  }

  build() {
    Column() {
      NavBar({ title: this.t('匠人主页', 'Artisan'), showBack: true })

      if (!this.artisan) {
        Column() {
          Text('🏺')
            .fontSize(this.fs(48))
            .opacity(0.5)
          Text(this.t('匠人不存在', 'Artisan not found'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textHint(this.theme))
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else {
        Scroll() {
          Column() {
            // 个人信息头部 — 国风背景
            Column() {
              Image(this.artisan!.avatar)
                .width(88)
                .height(88)
                .borderRadius(44)
                .objectFit(ImageFit.Cover)
                .border({ width: 3, color: Theme.gold(this.theme) })

              Text(this.artisan!.name)
                .fontSize(this.fs(24))
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.textPrimary(this.theme))
                .margin({ top: 14 })
                .letterSpacing(2)

              // 认证头衔 — 印章式
              Text(this.artisan!.title)
                .fontSize(this.fs(12))
                .fontColor(this.artisan!.level >= 3 ? Theme.gold(this.theme) : Theme.primary(this.theme))
                .padding({ left: 12, right: 12, top: 5, bottom: 5 })
                .border({ width: 1.5, color: this.artisan!.level >= 3 ? Theme.gold(this.theme) : Theme.primary(this.theme) })
                .borderRadius(3)
                .margin({ top: 10 })

              Text(`${this.artisan!.craftType} · ${this.artisan!.province}${this.artisan!.city}`)
                .fontSize(this.fs(13))
                .fontColor(Theme.textSecondary(this.theme))
                .margin({ top: 10 })
            }
            .width('100%')
            .padding({ top: 28, bottom: 24 })
            .backgroundColor(Theme.card(this.theme))
            .alignItems(HorizontalAlign.Center)

            // 数据统计
            Row() {
              this.NumItem(this.t('作品', 'Works'), this.artisan!.worksCount)
              Divider().vertical(true).height(32).color(Theme.divider(this.theme))
              this.NumItem(this.t('关注', 'Followers'), this.artisan!.followersCount)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card(this.theme))

            // 个人介绍
            Column() {
              Row() {
                Column()
                  .width(3).height(18).backgroundColor(Theme.primary(this.theme))
                  .margin({ right: 8 })
                Text(this.t('匠人简介', 'About'))
                  .fontSize(this.fs(16))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme))
              }
              .width('100%')

              Text(this.artisan!.intro)
                .fontSize(this.fs(13))
                .fontColor(Theme.textSecondary(this.theme))
                .lineHeight(22)
                .width('100%')
                .margin({ top: 10 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card(this.theme))
            .margin({ top: 8 })

            // 作品列表
            Column() {
              Row() {
                Column()
                  .width(3).height(18).backgroundColor(Theme.primary(this.theme))
                  .margin({ right: 8 })
                Text(this.t('在售作品', 'Works for Sale'))
                  .fontSize(this.fs(16))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme))
              }
              .width('100%')

              Grid() {
                ForEach(this.works, (product: Product) => {
                  GridItem() {
                    ProductCard({
                      product: product,
                      onItemClick: (p: Product) => {
                        router.pushUrl({ url: Constants.PAGE_PRODUCT_DETAIL, params: { productId: p.id } })
                      }
                    })
                  }
                })
              }
              .columnsTemplate('1fr 1fr')
              .columnsGap(10)
              .rowsGap(10)
              .width('100%')
              .margin({ top: 10 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card(this.theme))
            .margin({ top: 8 })

            Row().height(80)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Theme.bg(this.theme))
        .scrollBar(BarState.Off)

        // 底部操作栏
        Row() {
          Button(this.artisan!.isFollowed ? this.t('已关注', 'Following') : `+ ${this.t('关注匠人', 'Follow')}`)
            .fontSize(this.fs(15))
            .backgroundColor(this.artisan!.isFollowed ? Theme.divider(this.theme) : Theme.accent(this.theme))
            .fontColor(this.artisan!.isFollowed ? Theme.textHint(this.theme) : Theme.WHITE)
            .borderRadius(4)
            .height(44)
            .layoutWeight(1)
            .onClick(() => { this.toggleFollow() })

          Button('💬 ' + this.t('联系匠人', 'Contact'))
            .fontSize(this.fs(15))
            .backgroundColor(Theme.primary(this.theme))
            .fontColor(Theme.WHITE)
            .borderRadius(4)
            .height(44)
            .layoutWeight(1)
            .margin({ left: 12 })
            .onClick(async () => {
              if (!this.artisan) return
              const userResp = await AuthService.getUserInfo()
              if (userResp.code !== 0 || !userResp.data) {
                promptAction.showToast({ message: this.t('请先登录', 'Please login first') })
                return
              }
              const myId = Number(userResp.data.id)
              const artisanUserId = Number(this.artisan!.userId)
              if (myId === artisanUserId) {
                promptAction.showToast({ message: this.t('不能和自己聊天哦', 'Cannot chat with yourself') })
                return
              }
              router.pushUrl({
                url: Constants.PAGE_CHAT_DETAIL,
                params: {
                  otherId: this.artisan!.userId,
                  otherName: this.artisan!.name
                }
              })
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .backgroundColor(Theme.card(this.theme))
        .border({ width: { top: 0.5 }, color: Theme.divider(this.theme) })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }

  @Builder
  NumItem(label: string, num: number) {
    Column() {
      Text(`${num}`)
        .fontSize(this.fs(18))
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.textPrimary(this.theme))
      Text(label)
        .fontSize(this.fs(12))
        .fontColor(Theme.textSecondary(this.theme))
        .margin({ top: 2 })
    }
    .layoutWeight(1)
  }
}
