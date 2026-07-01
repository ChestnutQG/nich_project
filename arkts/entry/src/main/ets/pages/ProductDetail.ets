// 作品详情页 — 以非遗文化展示为核心 · 国风版
// 购买入口折叠隐藏，底部有评论区
import { router, promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Product, Sku, CraftStep } from '../model/Product'
import { ProductService } from '../service/ProductService'
import { CartService, CartItem } from '../service/CartService'
import { FavoriteService } from '../service/FavoriteService'
import { AuthService } from '../service/AuthService'
import { ArtisanService } from '../service/ArtisanService'
import { CommentService } from '../service/CommentService'
import { RatingStars } from '../components/RatingStars'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

// 评论数据模型
interface Comment {
  id: string
  userId: string
  userName: string
  avatar: string
  content: string
  time: string
}

@Entry
@Component
struct ProductDetail {
  @State product: Product | undefined = undefined
  @State selectedSku: Sku | undefined = undefined
  @State loading: boolean = true
  @State showBuySection: boolean = false
  @State comments: Comment[] = []
  @State commentText: string = ''
  private productId: string = ''

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
    if (params && params['productId']) {
      this.productId = params['productId']
      this.loadProduct()
      this.loadComments()
    }
  }

  async loadProduct(): Promise<void> {
    const resp = await ProductService.fetchProductDetail(this.productId)
    if (resp.code === 0 && resp.data) {
      this.product = resp.data
      this.selectedSku = resp.data.skus[0]
    }
    this.loading = false
  }

  async loadComments(): Promise<void> {
    const resp = await CommentService.fetchComments(this.productId)
    if (resp.code === 0) {
      this.comments = resp.data
    }
  }

  private openUserProfile(userId: string): void {
    if (!userId) return
    router.pushUrl({ url: Constants.PAGE_USER_PROFILE, params: { userId } })
  }

  async submitComment(): Promise<void> {
    const text = this.commentText.trim()
    if (!text) return
    const resp = await CommentService.addComment(this.productId, text)
    if (resp.code === 0) {
      this.commentText = ''
      this.loadComments()
    } else {
      promptAction.showToast({ message: resp.message || this.t('评论失败', 'Failed') })
    }
  }

  async toggleCollect(): Promise<void> {
    if (!this.product) return
    const willCollect = !this.product.isCollect
    const resp = willCollect
      ? await FavoriteService.add(this.product.id)
      : await FavoriteService.remove(this.product.id)
    if (resp.code === 0) {
      this.product.isCollect = willCollect
      promptAction.showToast({ message: willCollect ? this.t('已收藏', 'Collected') : this.t('已取消收藏', 'Removed') })
    } else {
      promptAction.showToast({ message: resp.message || this.t('操作失败', 'Failed') })
    }
  }

  build() {
    Column() {
      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Theme.primary(this.theme))
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else if (!this.product) {
        Column() {
          Text('🏺')
            .fontSize(this.fs(48))
            .opacity(0.5)
          Text(this.t('作品不存在', 'Not found'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textHint(this.theme))
            .margin({ top: 12 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else {
        Scroll() {
          Column() {
            // ===== 图片轮播 =====
            Swiper() {
              ForEach(this.product!.images, (img: string) => {
                Image(img)
                  .width('100%')
                  .height(375)
                  .objectFit(ImageFit.Cover)
              })
            }
            .width('100%')
            .height(375)
            .indicatorStyle({ selectedColor: Theme.primary(this.theme) })

            // ===== 匠人信息 =====
            Row() {
              Image(this.product!.artisanAvatar || 'https://picsum.photos/seed/craft/48/48')
                .width(44)
                .height(44)
                .borderRadius(22)
                .objectFit(ImageFit.Cover)
                .border({ width: 2, color: Theme.gold(this.theme) })

              Column() {
                Text(this.product!.artisanName)
                  .fontSize(this.fs(15))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme))
                Text(this.t('非遗传承人', 'Heritage Artisan'))
                  .fontSize(this.fs(10))
                  .fontColor(Theme.gold(this.theme))
                  .margin({ top: 2 })
              }
              .margin({ left: 10 })
              .alignItems(HorizontalAlign.Start)

              Blank()

              Row() {
                Text('💬 ' + this.t('联系', 'Chat'))
                  .fontSize(this.fs(11))
                  .fontColor(Theme.WHITE)
                  .backgroundColor(Theme.primary(this.theme))
                  .borderRadius(3)
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .margin({ right: 10 })
                  .onClick(async () => {
                    if (!this.product || !this.product.artisanId) return
                    const userResp = await AuthService.getUserInfo()
                    if (userResp.code !== 0 || !userResp.data) {
                      promptAction.showToast({ message: this.t('请先登录', 'Please login first') })
                      return
                    }
                    const artResp = await ArtisanService.fetchDetail(this.product!.artisanId)
                    if (artResp.code === 0 && artResp.data) {
                      const myId = Number(userResp.data.id)
                      const artUserId = Number(artResp.data.userId)
                      if (myId === artUserId) {
                        promptAction.showToast({ message: this.t('这是你自己的作品哦', 'This is your own work') })
                        return
                      }
                      router.pushUrl({
                        url: Constants.PAGE_CHAT_DETAIL,
                        params: {
                          otherId: artResp.data.userId,
                          otherName: this.product!.artisanName
                        }
                      })
                    }
                  })

                Row() {
                  Text(this.t('匠人主页', 'Profile'))
                    .fontSize(this.fs(12))
                    .fontColor(Theme.primary(this.theme))
                  Image($r('sys.media.ohos_ic_public_arrow_right'))
                    .width(12)
                    .height(12)
                    .fillColor(Theme.primary(this.theme))
                }
                .onClick(() => {
                  if (this.product && this.product.artisanId) {
                    router.pushUrl({
                      url: Constants.PAGE_ARTISAN_DETAIL,
                      params: { artisanId: this.product.artisanId }
                    })
                  }
                })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor(Theme.card(this.theme))
            .border({ width: { bottom: 0.5 }, color: Theme.divider(this.theme) })

            // ===== 作品标题与描述 =====
            Column() {
              Text(this.product!.name)
                .fontSize(this.fs(20))
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.textPrimary(this.theme))
                .width('100%')
                .lineHeight(28)

              Text(this.product!.description)
                .fontSize(this.fs(14))
                .fontColor(Theme.textSecondary(this.theme))
                .width('100%')
                .margin({ top: 8 })
                .lineHeight(22)

              Row() {
                Text(this.product!.categoryName)
                  .fontSize(this.fs(10))
                  .fontColor(Theme.primary(this.theme))
                  .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                  .borderRadius(3)
                  .backgroundColor(Theme.primaryBg(this.theme))

                Text(this.product!.region)
                  .fontSize(this.fs(11))
                  .fontColor(Theme.textSecondary(this.theme))
                  .margin({ left: 8 })

                Text('·')
                  .fontSize(this.fs(11))
                  .fontColor(Theme.textHint(this.theme))

                Text(this.product!.craftType)
                  .fontSize(this.fs(11))
                  .fontColor(Theme.textSecondary(this.theme))
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 20 })
            .backgroundColor(Theme.card(this.theme))

            // ===== 文化故事 =====
            Column() {
              Row() {
                Column()
                  .width(3).height(18).backgroundColor(Theme.primary(this.theme))
                  .margin({ right: 8 })
                Text(this.t('文化故事', 'Story'))
                  .fontSize(this.fs(17))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme))
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 })

              Text(this.product!.story)
                .fontSize(this.fs(14))
                .fontColor(Theme.textSecondary(this.theme))
                .lineHeight(24)
                .width('100%')
                .padding({ left: 16, right: 16, top: 10, bottom: 20 })
            }
            .width('100%')
            .margin({ top: 10 })
            .backgroundColor(Theme.card(this.theme))
            .border({ width: { left: 2 }, color: Theme.primaryBg(this.theme) })

            // ===== 制作工艺 =====
            if (this.product!.craftProcess.length > 0) {
              Column() {
                Row() {
                  Column()
                    .width(3).height(18).backgroundColor(Theme.primary(this.theme))
                    .margin({ right: 8 })
                  Text(this.t('制作工艺', 'Craft Process'))
                    .fontSize(this.fs(17))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.textPrimary(this.theme))
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 16 })

                ForEach(this.product!.craftProcess, (step: CraftStep, index: number) => {
                  Row() {
                    Text(`${index + 1}`)
                      .fontSize(this.fs(13))
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.primary(this.theme))
                      .width(24).height(24)
                      .borderRadius(3)
                      .backgroundColor(Theme.primaryBg(this.theme))
                      .textAlign(TextAlign.Center)
                      .lineHeight(24)

                    Column() {
                      Text(step.title)
                        .fontSize(this.fs(14))
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.textPrimary(this.theme))
                      Text(step.description)
                        .fontSize(this.fs(12))
                        .fontColor(Theme.textSecondary(this.theme))
                        .margin({ top: 4 })
                        .lineHeight(18)
                    }
                    .layoutWeight(1)
                    .margin({ left: 12 })
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                })

                Row().height(16)
              }
              .width('100%')
              .margin({ top: 10 })
              .backgroundColor(Theme.card(this.theme))
            }

            // ===== 鉴赏评价 =====
            Column() {
              Row() {
                Column()
                  .width(3).height(18).backgroundColor(Theme.primary(this.theme))
                  .margin({ right: 8 })
                Text(this.t('鉴赏评价', 'Reviews'))
                  .fontSize(this.fs(17))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme))
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 })

              Row() {
                RatingStars({ rating: this.product!.rating, starSize: 18 })
                Text(`${this.product!.rating.toFixed(1)}`)
                  .fontSize(this.fs(18))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.gold(this.theme))
                  .margin({ left: 8 })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 20 })
            }
            .width('100%')
            .margin({ top: 10 })
            .backgroundColor(Theme.card(this.theme))

            // ===== 评论区 =====
            Column() {
              Row() {
                Column()
                  .width(3).height(18).backgroundColor(Theme.primary(this.theme))
                  .margin({ right: 8 })
                Text(`${this.t('评论', 'Comments')} (${this.comments.length})`)
                  .fontSize(this.fs(17))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme))
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 })

              ForEach(this.comments, (cmt: Comment) => {
                Row() {
                  if (cmt.avatar) {
                    Image(cmt.avatar)
                      .width(32).height(32)
                      .borderRadius(16)
                      .objectFit(ImageFit.Cover)
                      .onClick(() => { this.openUserProfile(cmt.userId) })
                  } else {
                    Text(cmt.userName.charAt(0))
                      .fontSize(this.fs(14))
                      .fontColor(Theme.WHITE)
                      .width(32).height(32)
                      .borderRadius(16)
                      .backgroundColor(Theme.gold(this.theme))
                      .textAlign(TextAlign.Center)
                      .lineHeight(32)
                      .onClick(() => { this.openUserProfile(cmt.userId) })
                  }

                  Column() {
                    Row() {
                      Text(cmt.userName)
                        .fontSize(this.fs(13))
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.textPrimary(this.theme))
                        .onClick(() => { this.openUserProfile(cmt.userId) })
                      Blank()
                      Text(cmt.time)
                        .fontSize(this.fs(11))
                        .fontColor(Theme.textHint(this.theme))
                    }
                    .width('100%')

                    Text(cmt.content)
                      .fontSize(this.fs(13))
                      .fontColor(Theme.textSecondary(this.theme))
                      .lineHeight(20)
                      .margin({ top: 4 })
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .margin({ left: 10 })
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              })

              // 评论输入区
              Row() {
                TextInput({ placeholder: this.t('写下你的想法…', 'Write your thoughts...'), text: this.commentText })
                  .fontSize(this.fs(13))
                  .placeholderColor(Theme.textHint(this.theme))
                  .backgroundColor(Theme.bg(this.theme))
                  .borderRadius(4)
                  .height(34)
                  .layoutWeight(1)
                  .onChange((v: string) => { this.commentText = v })

                Text(this.t('发送', 'Send'))
                  .fontSize(this.fs(13))
                  .fontColor(this.commentText.trim() ? Theme.primary(this.theme) : Theme.textHint(this.theme))
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 10 })
                  .onClick(() => { this.submitComment() })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 16 })
            }
            .width('100%')
            .margin({ top: 10 })
            .backgroundColor(Theme.card(this.theme))

            // ===== 购买入口 =====
            if ((this.product!.isSellable !== false)) {
              Column() {
                Divider().color(Theme.divider(this.theme)).width('100%').margin({ left: 16, right: 16 })

                if (!this.showBuySection) {
                  Row() {
                    Text(this.product!.isCollect ? '❤️' : '🤍')
                      .fontSize(this.fs(15))
                      .margin({ right: 6 })
                      .onClick(() => { this.toggleCollect() })
                    Text(`${this.t('支持匠人', 'Support')} · ¥${((this.selectedSku?.price || 0) / 100).toFixed(2)}`)
                      .fontSize(this.fs(12))
                      .fontColor(Theme.textHint(this.theme))
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                  .onClick(() => { this.showBuySection = true })
                } else {
                  Column() {
                    Row() {
                      Text(this.t('支持这位手艺人', 'Support this artisan'))
                        .fontSize(this.fs(14))
                        .fontColor(Theme.textPrimary(this.theme))
                      Blank()
                      Text(this.t('收起 ▲', 'Collapse ▲'))
                        .fontSize(this.fs(11))
                        .fontColor(Theme.textHint(this.theme))
                        .onClick(() => { this.showBuySection = false })
                    }
                    .width('100%')

                    Row() {
                      Text(`¥${((this.selectedSku?.price || 0) / 100).toFixed(2)}`)
                        .fontSize(this.fs(16))
                        .fontWeight(FontWeight.Bold)
                        .fontColor(Theme.primary(this.theme))
                      if (this.selectedSku) {
                        Text(this.selectedSku.name)
                          .fontSize(this.fs(11))
                          .fontColor(Theme.textSecondary(this.theme))
                          .margin({ left: 8 })
                      }
                    }
                    .width('100%')
                    .margin({ top: 10 })

                    Row() {
                      Button(this.t('加入购物车', 'Add to Cart'))
                        .fontSize(this.fs(12))
                        .backgroundColor(Theme.accent(this.theme))
                        .borderRadius(4)
                        .height(32)
                        .layoutWeight(1)
                        .margin({ right: 8 })
                        .onClick(async () => {
                          if (!this.product || !this.selectedSku) {
                            promptAction.showToast({ message: this.t('请先选择规格', 'Please select a spec') })
                            return
                          }
                          const resp = await CartService.addToCart(
                            this.product.id,
                            this.selectedSku.id,
                            1,
                            this.product.name,
                            this.product.images[0],
                            this.product.artisanName,
                            this.selectedSku.name,
                            this.selectedSku.price
                          )
                          if (resp.code === 0) {
                            promptAction.showToast({ message: this.t('已加入购物车', 'Added to cart') })
                          } else {
                            promptAction.showToast({ message: resp.message || this.t('加入购物车失败', 'Failed') })
                          }
                        })

                      Button(this.t('立即购买', 'Buy Now'))
                        .fontSize(this.fs(12))
                        .backgroundColor(Theme.primary(this.theme))
                        .borderRadius(4)
                        .height(32)
                        .layoutWeight(1)
                        .onClick(() => {
                          router.pushUrl({
                            url: Constants.PAGE_ORDER_CONFIRM,
                            params: { productId: this.product!.id, skuId: this.selectedSku!.id }
                          })
                        })
                    }
                    .width('100%')
                    .margin({ top: 10 })
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                }
              }
              .width('100%')
              .backgroundColor(Theme.card(this.theme))
              .margin({ top: 10 })
            }

            Row().height(20)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Theme.bg(this.theme))
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }
}
