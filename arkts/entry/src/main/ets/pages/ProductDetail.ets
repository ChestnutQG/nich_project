// 作品详情页 — 以非遗文化展示为核心
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
import { RatingStars } from '../components/RatingStars'

// 评论数据模型
interface Comment {
  id: string
  userName: string
  avatar: string
  content: string
  time: string
}

// 模拟评论
const MOCK_COMMENTS: Comment[] = [
  {
    id: 'cmt1',
    userName: '非遗文化爱好者',
    avatar: '',
    content: '太美了！每一针每一线都是文化的传承，苏绣真的是我们民族的瑰宝。请问这个团扇的丝线用的是几丝的？',
    time: '3天前'
  },
  {
    id: 'cmt2',
    userName: '手艺人小张',
    avatar: '',
    content: '看到沈老师的作品真的很感动，我学苏绣三年了，双面绣到现在都做不好。向老一辈手艺人致敬！',
    time: '5天前'
  },
  {
    id: 'cmt3',
    userName: '传统文化爱好者',
    avatar: '',
    content: '去年在苏州博物馆看到过类似的作品，实物比照片震撼太多了，那种丝线的光泽感照片拍不出来。',
    time: '1周前'
  }
]

@Entry
@Component
struct ProductDetail {
  @State product: Product | undefined = undefined
  @State selectedSku: Sku | undefined = undefined
  @State loading: boolean = true
  @State showBuySection: boolean = false
  @State comments: Comment[] = MOCK_COMMENTS
  @State commentText: string = ''
  private productId: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    if (params && params['productId']) {
      this.productId = params['productId']
      this.loadProduct()
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

  // 收藏 / 取消收藏
  async toggleCollect(): Promise<void> {
    if (!this.product) return
    const willCollect = !this.product.isCollect
    const resp = willCollect
      ? await FavoriteService.add(this.product.id)
      : await FavoriteService.remove(this.product.id)
    if (resp.code === 0) {
      this.product.isCollect = willCollect
      promptAction.showToast({ message: willCollect ? '已收藏' : '已取消收藏' })
    } else {
      promptAction.showToast({ message: resp.message || '操作失败' })
    }
  }

  build() {
    Column() {
      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Colors.PRIMARY)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (!this.product) {
        Column() {
          Text('作品不存在').fontSize(16).fontColor(Colors.TEXT_HINT)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
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
            .indicatorStyle({ selectedColor: Colors.PRIMARY })

            // ===== 匠人信息 =====
            Row() {
              Image('https://picsum.photos/seed/art01/48/48')
                .width(44)
                .height(44)
                .borderRadius(22)
                .objectFit(ImageFit.Cover)
                .border({ width: 1.5, color: Colors.GOLD })

              Column() {
                Text(this.product!.artisanName)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
                Text('非遗传承人')
                  .fontSize(11)
                  .fontColor(Colors.GOLD)
                  .margin({ top: 2 })
              }
              .margin({ left: 10 })
              .alignItems(HorizontalAlign.Start)

              Blank()

              Row() {
                Text('💬 联系')
                  .fontSize(12)
                  .fontColor(Colors.BG_WHITE)
                  .backgroundColor(Colors.PRIMARY)
                  .borderRadius(10)
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .margin({ right: 10 })
                  .onClick(async () => {
                    if (!this.product || !this.product.artisanId) return
                    const userResp = await AuthService.getUserInfo()
                    if (userResp.code !== 0 || !userResp.data) {
                      promptAction.showToast({ message: '请先登录' })
                      return
                    }
                    const artResp = await ArtisanService.fetchDetail(this.product!.artisanId)
                    if (artResp.code === 0 && artResp.data) {
                      const myId = Number(userResp.data.id)
                      const artUserId = Number(artResp.data.userId)
                      if (myId === artUserId) {
                        promptAction.showToast({ message: '这是你自己的作品哦' })
                        return
                      }
                      router.pushUrl({
                        url: Constants.PAGE_CHAT_DETAIL,
                        params: {
                          peerId: artUserId,
                          peerName: this.product!.artisanName,
                          currentUserId: myId
                        }
                      })
                    }
                  })

                Text('匠人主页')
                  .fontSize(12)
                  .fontColor(Colors.PRIMARY)
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(12)
                  .height(12)
                  .fillColor(Colors.PRIMARY)
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
            .backgroundColor(Colors.BG_WHITE)
            .margin({ top: 10 })

            // ===== 作品标题与描述 =====
            Column() {
              Text(this.product!.name)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .width('100%')
                .lineHeight(28)

              Text(this.product!.description)
                .fontSize(14)
                .fontColor(Colors.TEXT_SECONDARY)
                .width('100%')
                .margin({ top: 8 })
                .lineHeight(22)

              Row() {
                Text(this.product!.categoryName)
                  .fontSize(11)
                  .fontColor(Colors.PRIMARY)
                  .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                  .borderRadius(3)
                  .backgroundColor(Colors.PRIMARY_BG)

                Text(this.product!.region)
                  .fontSize(11)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .margin({ left: 8 })

                Text('·')
                  .fontSize(11)
                  .fontColor(Colors.TEXT_HINT)

                Text(this.product!.craftType)
                  .fontSize(11)
                  .fontColor(Colors.TEXT_SECONDARY)
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 20 })
            .backgroundColor(Colors.BG_WHITE)

            // ===== 文化故事 =====
            Column() {
              Row() {
                Column()
                  .width(3).height(18).backgroundColor(Colors.PRIMARY)
                  .margin({ right: 8 })
                Text('文化故事')
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 })

              Text(this.product!.story)
                .fontSize(14)
                .fontColor(Colors.TEXT_SECONDARY)
                .lineHeight(24)
                .width('100%')
                .padding({ left: 16, right: 16, top: 10, bottom: 20 })
            }
            .width('100%')
            .margin({ top: 10 })
            .backgroundColor(Colors.BG_WHITE)

            // ===== 制作工艺 =====
            if (this.product!.craftProcess.length > 0) {
              Column() {
                Row() {
                  Column()
                    .width(3).height(18).backgroundColor(Colors.PRIMARY)
                    .margin({ right: 8 })
                  Text('制作工艺')
                    .fontSize(17)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Colors.TEXT_PRIMARY)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 16 })

                ForEach(this.product!.craftProcess, (step: CraftStep, index: number) => {
                  Row() {
                    Text(`${index + 1}`)
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Colors.PRIMARY)
                      .width(24).height(24)
                      .borderRadius(12)
                      .backgroundColor(Colors.PRIMARY_BG)
                      .textAlign(TextAlign.Center)
                      .lineHeight(24)

                    Column() {
                      Text(step.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Colors.TEXT_PRIMARY)
                      Text(step.description)
                        .fontSize(12)
                        .fontColor(Colors.TEXT_SECONDARY)
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
              .backgroundColor(Colors.BG_WHITE)
            }

            // ===== 鉴赏评价 =====
            Column() {
              Row() {
                Column()
                  .width(3).height(18).backgroundColor(Colors.PRIMARY)
                  .margin({ right: 8 })
                Text('鉴赏评价')
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 })

              Row() {
                RatingStars({ rating: this.product!.rating, starSize: 18 })
                Text(`${this.product!.rating.toFixed(1)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.GOLD)
                  .margin({ left: 8 })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 20 })
            }
            .width('100%')
            .margin({ top: 10 })
            .backgroundColor(Colors.BG_WHITE)

            // ===== 评论区 =====
            Column() {
              Row() {
                Column()
                  .width(3).height(18).backgroundColor(Colors.PRIMARY)
                  .margin({ right: 8 })
                Text(`评论 (${this.comments.length})`)
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16 })

              // 评论列表
              ForEach(this.comments, (cmt: Comment) => {
                Row() {
                  // 头像
                  Text(cmt.userName.charAt(0))
                    .fontSize(14)
                    .fontColor(Colors.BG_WHITE)
                    .width(32).height(32)
                    .borderRadius(16)
                    .backgroundColor(Colors.GOLD)
                    .textAlign(TextAlign.Center)
                    .lineHeight(32)

                  Column() {
                    Row() {
                      Text(cmt.userName)
                        .fontSize(13)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Colors.TEXT_PRIMARY)
                      Blank()
                      Text(cmt.time)
                        .fontSize(11)
                        .fontColor(Colors.TEXT_HINT)
                    }
                    .width('100%')

                    Text(cmt.content)
                      .fontSize(13)
                      .fontColor(Colors.TEXT_SECONDARY)
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
                TextInput({ placeholder: '写下你的想法…' })
                  .fontSize(13)
                  .placeholderColor(Colors.TEXT_HINT)
                  .backgroundColor(Colors.BG_PAPER)
                  .borderRadius(16)
                  .height(34)
                  .layoutWeight(1)
                  .onChange((v: string) => { this.commentText = v })

                Text('发送')
                  .fontSize(13)
                  .fontColor(this.commentText.trim() ? Colors.PRIMARY : Colors.TEXT_HINT)
                  .margin({ left: 10 })
                  .onClick(() => {
                    if (this.commentText.trim()) {
                      const newComment: Comment = {
                        id: `cmt${Date.now()}`,
                        userName: '非遗爱好者',
                        avatar: '',
                        content: this.commentText.trim(),
                        time: '刚刚'
                      }
                      this.comments = [newComment, ...this.comments]
                      this.commentText = ''
                    }
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 16 })
            }
            .width('100%')
            .margin({ top: 10 })
            .backgroundColor(Colors.BG_WHITE)

            // ===== 购买入口（可售卖时，折叠隐藏） =====
            if ((this.product!.isSellable !== false)) {
              Column() {
                Divider().color(Colors.DIVIDER).width('100%').margin({ left: 16, right: 16 })

                if (!this.showBuySection) {
                  // 折叠态：极小的入口提示
                  Row() {
                    Text(this.product!.isCollect ? '❤️' : '🤍')
                      .fontSize(15)
                      .margin({ right: 6 })
                      .onClick(() => { this.toggleCollect() })
                    Text(`支持匠人 · ¥${((this.selectedSku?.price || 0) / 100).toFixed(2)}`)
                      .fontSize(12)
                      .fontColor(Colors.TEXT_HINT)
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                  .onClick(() => { this.showBuySection = true })
                } else {
                  // 展开态
                  Column() {
                    Row() {
                      Text('支持这位手艺人')
                        .fontSize(14)
                        .fontColor(Colors.TEXT_PRIMARY)
                      Blank()
                      Text('收起 ▲')
                        .fontSize(11)
                        .fontColor(Colors.TEXT_HINT)
                        .onClick(() => { this.showBuySection = false })
                    }
                    .width('100%')

                    Row() {
                      Text(`¥${((this.selectedSku?.price || 0) / 100).toFixed(2)}`)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(Colors.PRIMARY)
                      if (this.selectedSku) {
                        Text(this.selectedSku.name)
                          .fontSize(11)
                          .fontColor(Colors.TEXT_SECONDARY)
                          .margin({ left: 8 })
                      }
                    }
                    .width('100%')
                    .margin({ top: 10 })

                    Row() {
                      Button('加入购物车')
                        .fontSize(12)
                        .backgroundColor(Colors.GOLD)
                        .borderRadius(14)
                        .height(32)
                        .layoutWeight(1)
                        .margin({ right: 8 })
                        .onClick(async () => {
                          if (!this.product || !this.selectedSku) {
                            promptAction.showToast({ message: '请先选择规格' })
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
                            promptAction.showToast({ message: '已加入购物车' })
                          } else {
                            promptAction.showToast({ message: resp.message || '加入购物车失败' })
                          }
                        })

                      Button('立即购买')
                        .fontSize(12)
                        .backgroundColor(Colors.PRIMARY)
                        .borderRadius(14)
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
              .backgroundColor(Colors.BG_WHITE)
              .margin({ top: 10 })
            }

            Row().height(20)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Colors.BG_PAPER)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
  }
}
