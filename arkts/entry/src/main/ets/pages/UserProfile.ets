// 用户公开主页 — 任何人可查看：资料 + 匠人作品 + 私信/关注
import { router, promptAction } from '@kit.ArkUI'
import { Constants } from '../common/Constants'
import { Product } from '../model/Product'
import { NavBar } from '../components/NavBar'
import { ProductCard } from '../components/ProductCard'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'
import { UserProfileService, PublicProfile } from '../service/UserProfileService'
import { ArtisanService } from '../service/ArtisanService'
import { FollowService } from '../service/FollowService'
import { AuthService } from '../service/AuthService'

@Entry
@Component
struct UserProfile {
  @State profile: PublicProfile | undefined = undefined
  @State works: Product[] = []
  @State loading: boolean = true
  @State isSelf: boolean = false
  @State showEditIntro: boolean = false
  @State introText: string = ''
  @State savingIntro: boolean = false
  private userId: string = ''

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
    if (params && params['userId']) {
      this.userId = params['userId']
      this.loadProfile()
    }
  }

  async loadProfile(): Promise<void> {
    this.loading = true
    // 判断是否本人
    const meResp = await AuthService.getUserInfo()
    if (meResp.code === 0 && meResp.data) {
      this.isSelf = `${meResp.data.id}` === this.userId
    }
    const resp = await UserProfileService.fetchProfile(this.userId)
    if (resp.code === 0 && resp.data) {
      this.profile = resp.data
      if (this.profile.isArtisan && this.profile.artisanId) {
        const worksResp = await ArtisanService.fetchProducts(this.profile.artisanId)
        if (worksResp.code === 0) this.works = worksResp.data
      }
    } else {
      promptAction.showToast({ message: resp.message || this.t('用户不存在', 'User not found') })
    }
    this.loading = false
  }

  async toggleFollow(): Promise<void> {
    if (!this.profile || !this.profile.artisanId) return
    const willFollow = !this.profile.isFollowed
    const resp = willFollow
      ? await FollowService.follow(this.profile.artisanId)
      : await FollowService.unfollow(this.profile.artisanId)
    if (resp.code === 0) {
      this.profile.isFollowed = willFollow
      this.profile.followersCount = (this.profile.followersCount || 0) + (willFollow ? 1 : -1)
      promptAction.showToast({ message: willFollow ? this.t('已关注', 'Followed') : this.t('已取消关注', 'Unfollowed') })
    } else {
      promptAction.showToast({ message: resp.message || this.t('操作失败', 'Failed') })
    }
  }

  private contact(): void {
    if (!this.profile) return
    router.pushUrl({
      url: Constants.PAGE_CHAT_DETAIL,
      params: { otherId: this.profile.id, otherName: this.profile.nickname }
    })
  }

  private openEditIntro(): void {
    this.introText = this.profile && this.profile.intro ? this.profile.intro : ''
    this.showEditIntro = true
  }

  async saveIntro(): Promise<void> {
    const text = this.introText.trim()
    this.savingIntro = true
    const resp = await UserProfileService.updateMyIntro(text)
    this.savingIntro = false
    if (resp.code === 0) {
      if (this.profile) { this.profile.intro = text }
      this.showEditIntro = false
      promptAction.showToast({ message: this.t('已保存', 'Saved') })
    } else {
      promptAction.showToast({ message: resp.message || this.t('保存失败', 'Failed') })
    }
  }

  build() {
    Stack() {
      Column() {
      NavBar({ title: this.t('主页', 'Profile'), showBack: true })

      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Theme.primary(this.theme))
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else if (!this.profile) {
        Column() {
          Text(this.t('用户不存在', 'User not found'))
            .fontSize(this.fs(14)).fontColor(Theme.textHint(this.theme))
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else {
        Scroll() {
          Column() {
            // 头部资料
            Column() {
              Image(this.profile!.avatar || 'https://picsum.photos/seed/user/120/120')
                .width(80).height(80).borderRadius(40).objectFit(ImageFit.Cover)
                .border({ width: 2, color: this.profile!.isArtisan ? Theme.gold(this.theme) : Theme.divider(this.theme) })

              Text(this.profile!.nickname)
                .fontSize(this.fs(20)).fontWeight(FontWeight.Bold)
                .fontColor(Theme.textPrimary(this.theme)).margin({ top: 12 })

              if (this.profile!.isArtisan) {
                Text(this.profile!.title || this.t('非遗匠人', 'Artisan'))
                  .fontSize(this.fs(12)).fontColor(Theme.gold(this.theme))
                  .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                  .borderRadius(4).backgroundColor(Theme.primaryBg(this.theme))
                  .margin({ top: 8 })

                Text(`${this.profile!.craftType || ''} · ${this.profile!.province || ''}${this.profile!.city || ''}`)
                  .fontSize(this.fs(12)).fontColor(Theme.textSecondary(this.theme)).margin({ top: 8 })

                Row() {
                  this.StatBox(`${this.works.length}`, this.t('作品', 'Works'))
                  this.StatBox(`${this.profile!.followersCount || 0}`, this.t('粉丝', 'Followers'))
                }
                .margin({ top: 14 })
              } else {
                Text(this.t('普通用户', 'User'))
                  .fontSize(this.fs(12)).fontColor(Theme.textHint(this.theme)).margin({ top: 8 })
              }
            }
            .width('100%').padding({ top: 24, bottom: 20 })
            .backgroundColor(Theme.card(this.theme)).alignItems(HorizontalAlign.Center)

            // 匠人简介
            if (this.profile!.isArtisan) {
              Column() {
                Row() {
                  Text(this.t('简介', 'About'))
                    .fontSize(this.fs(15)).fontWeight(FontWeight.Medium)
                    .fontColor(Theme.textPrimary(this.theme))
                  Blank()
                  if (this.isSelf) {
                    Text(this.t('编辑', 'Edit'))
                      .fontSize(this.fs(12)).fontColor(Theme.primary(this.theme))
                      .onClick(() => { this.openEditIntro() })
                  }
                }
                .width('100%')

                Text(this.profile!.intro ? this.profile!.intro :
                  (this.isSelf
                    ? this.t('还没有简介，点右上角编辑', 'No intro yet, tap Edit')
                    : this.t('这位传承人还没有填写简介', 'This artisan has not added an introduction yet')))
                  .fontSize(this.fs(13))
                  .fontColor(this.profile!.intro ? Theme.textSecondary(this.theme) : Theme.textHint(this.theme))
                  .lineHeight(22).width('100%').margin({ top: 8 })
              }
              .width('100%').padding(16).backgroundColor(Theme.card(this.theme)).margin({ top: 8 })
            }

            // 作品列表
            if (this.works.length > 0) {
              Column() {
                Text(this.t('发布的作品', 'Works'))
                  .fontSize(this.fs(15)).fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme)).width('100%')
                Grid() {
                  ForEach(this.works, (product: Product) => {
                    GridItem() {
                      ProductCard({
                        product: product,
                        hideCommerceInfo: true,
                        onItemClick: (p: Product) => {
                          router.pushUrl({ url: Constants.PAGE_PRODUCT_DETAIL, params: { productId: p.id } })
                        }
                      })
                    }
                  })
                }
                .columnsTemplate('1fr 1fr').columnsGap(10).rowsGap(10)
                .width('100%').margin({ top: 10 })
              }
              .width('100%').padding(16).backgroundColor(Theme.card(this.theme)).margin({ top: 8 })
            } else {
              this.EmptyWorks()
            }

            Row().height(80)
          }
        }
        .width('100%').layoutWeight(1)
        .backgroundColor(Theme.bg(this.theme)).scrollBar(BarState.Off)

        // 底部操作栏（非本人时显示）
        if (!this.isSelf) {
          Row() {
            if (this.profile!.isArtisan) {
              Button(this.profile!.isFollowed ? this.t('已关注', 'Following') : `+ ${this.t('关注', 'Follow')}`)
                .fontSize(this.fs(15))
                .backgroundColor(this.profile!.isFollowed ? Theme.divider(this.theme) : Theme.primary(this.theme))
                .fontColor(this.profile!.isFollowed ? Theme.textHint(this.theme) : Theme.WHITE)
                .borderRadius(24).height(44).layoutWeight(1)
                .onClick(() => { this.toggleFollow() })
            }
            Button('💬 ' + this.t('私信', 'Message'))
              .fontSize(this.fs(15))
              .backgroundColor(Theme.primary(this.theme)).fontColor(Theme.WHITE)
              .borderRadius(24).height(44).layoutWeight(1)
              .margin({ left: this.profile!.isArtisan ? 12 : 0 })
              .onClick(() => { this.contact() })
          }
          .width('100%').padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.card(this.theme))
        }
      }
      }
      .width('100%').height('100%')
      .backgroundColor(Theme.bg(this.theme))

      // 编辑简介浮层
      if (this.showEditIntro) {
        this.EditIntroPanel()
      }
    }
    .width('100%').height('100%')
  }

  @Builder
  EmptyWorks() {
    Column() {
      Row() {
        Text(this.t('发布的作品', 'Works'))
          .fontSize(this.fs(15)).fontWeight(FontWeight.Medium)
          .fontColor(Theme.textPrimary(this.theme))
        Blank()
        Text('0')
          .fontSize(this.fs(11)).fontColor(Theme.textHint(this.theme))
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(10).backgroundColor(Theme.bg(this.theme))
      }
      .width('100%')

      Column() {
        Stack() {
          Column()
            .width(76).height(76).borderRadius(38)
            .backgroundColor(Theme.primaryBg(this.theme))
          Text(this.profile && this.profile.isArtisan ? '🪡' : '🏺')
            .fontSize(this.fs(34))
        }
        .width(76).height(76)

        Text(this.isSelf
          ? this.t('让第一件作品点亮主页', 'Let your first work light up this page')
          : this.t('手艺正在酝酿中', 'New work is taking shape'))
          .fontSize(this.fs(16)).fontWeight(FontWeight.Medium)
          .fontColor(Theme.textPrimary(this.theme)).margin({ top: 16 })

        Text(this.isSelf
          ? this.t('分享作品背后的技艺与故事，让更多人看见你的手艺。',
            'Share the craft and story behind your work.')
          : this.t('这里暂时还没有作品，先认识一下这位创作者吧。',
            'No works here yet. Get to know the creator first.'))
          .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme))
          .textAlign(TextAlign.Center).lineHeight(21)
          .width('82%').margin({ top: 8 })

        if (this.isSelf) {
          Button('+ ' + this.t('发布第一件作品', 'Publish First Work'))
            .fontSize(this.fs(14)).fontColor(Theme.WHITE)
            .height(40).padding({ left: 22, right: 22 })
            .borderRadius(20).backgroundColor(Theme.primary(this.theme))
            .margin({ top: 18 })
            .onClick(() => router.pushUrl({ url: Constants.PAGE_PRODUCT_PUBLISH }))
        } else {
          Row() {
            Column().width(24).height(1).backgroundColor(Theme.divider(this.theme))
            Text(this.t('敬请期待', 'Stay tuned'))
              .fontSize(this.fs(11)).fontColor(Theme.textHint(this.theme))
              .margin({ left: 8, right: 8 })
            Column().width(24).height(1).backgroundColor(Theme.divider(this.theme))
          }
          .margin({ top: 18 })
        }
      }
      .width('100%').padding({ top: 28, bottom: 26 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%').padding(16)
    .backgroundColor(Theme.card(this.theme)).margin({ top: 8 })
  }

  @Builder
  EditIntroPanel() {
    Column() {
      Column()
        .width('100%').layoutWeight(1).backgroundColor('#55000000')
        .onClick(() => { this.showEditIntro = false })

      Column() {
        Text(this.t('编辑匠人简介', 'Edit Intro'))
          .fontSize(this.fs(16)).fontWeight(FontWeight.Bold)
          .fontColor(Theme.textPrimary(this.theme)).margin({ bottom: 12 })

        TextArea({ placeholder: this.t('介绍一下你的手艺与故事…', 'Tell your craft story...'), text: this.introText })
          .fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
          .backgroundColor(Theme.bg(this.theme))
          .height(140).width('100%').borderRadius(8)
          .onChange((v: string) => { this.introText = v })

        Button(this.savingIntro ? this.t('保存中...', 'Saving...') : this.t('保存', 'Save'))
          .width('100%').height(46).margin({ top: 16 })
          .fontSize(this.fs(16)).fontColor(Theme.WHITE)
          .backgroundColor(Theme.primary(this.theme)).borderRadius(23)
          .enabled(!this.savingIntro)
          .onClick(() => { this.saveIntro() })
      }
      .width('100%').padding(20)
      .backgroundColor(Theme.card(this.theme))
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%').height('100%')
  }

  @Builder
  StatBox(value: string, label: string) {
    Column() {
      Text(value).fontSize(this.fs(18)).fontWeight(FontWeight.Bold).fontColor(Theme.textPrimary(this.theme))
      Text(label).fontSize(this.fs(12)).fontColor(Theme.textSecondary(this.theme)).margin({ top: 2 })
    }
    .margin({ left: 18, right: 18 })
  }
}
