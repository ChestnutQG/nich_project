// 主页 — 非遗文化内容 Feed 流
// 顶部导航 + 分类 chip + 作品卡片
// 左上角头像点击弹出侧边栏（从左侧滑入）
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Product } from '../model/Product'
import { Category } from '../model/Category'
import { ProductService } from '../service/ProductService'
import { CartService } from '../service/CartService'
import { ApiClient } from '../service/ApiClient'
import { MockCategories } from '../mock/MockCategories'
import { User } from '../model/User'

@Entry
@Component
struct Index {
  // Feed 数据
  @State feedProducts: Product[] = []
  @State feedLoading: boolean = true
  @State feedRefreshing: boolean = false

  // 用户数据（侧边栏用）
  @State userAvatar: string = ''
  @State userName: string = '非遗爱好者'
  @State userPhone: string = ''
  @State userCollectCount: number = 0
  @State userFollowCount: number = 0
  @State userOrderCount: number = 0
  @State cartCount: number = CartService.getCartCount()

  // 侧边栏状态
  @State showSideBar: boolean = false
  @State drawerOffset: number = -100  // -100 隐藏（左侧外），0 完全显示

  // 分类 chip 数据
  private categories: Category[] = MockCategories

  aboutToAppear(): void {
    this.loadFeedData()
    this.loadUserData()
  }

  onPageShow(): void {
    this.cartCount = CartService.getCartCount()
    this.loadUserData()
  }

  async loadFeedData(): Promise<void> {
    this.feedLoading = true
    const resp = await ProductService.fetchRecommendProducts()
    if (resp.code === 0) {
      this.feedProducts = resp.data
    }
    this.feedLoading = false
  }

  async loadUserData(): Promise<void> {
    const resp = await ApiClient.get<User>('/users/1')
    if (resp.code === 0 && resp.data) {
      this.userName = resp.data.nickname || '非遗爱好者'
      this.userAvatar = resp.data.avatar || ''
      this.userPhone = resp.data.phone || ''
      this.userCollectCount = resp.data.collectCount || 0
      this.userFollowCount = resp.data.followCount || 0
      this.userOrderCount = resp.data.orderCount || 0
    }
  }

  private openDrawer(): void {
    this.showSideBar = true
    animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
      this.drawerOffset = 0
    })
  }

  private closeDrawer(): void {
    animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.drawerOffset = -100
    })
    // 动画结束后隐藏遮罩
    setTimeout(() => {
      this.showSideBar = false
    }, 220)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 主内容区
      Column() {
        // 顶部导航栏
        Row() {
          // 头像按钮 — 有头像则显示头像，否则显示默认图标
          if (this.userAvatar) {
            Image(this.userAvatar)
              .width(28)
              .height(28)
              .borderRadius(14)
              .objectFit(ImageFit.Cover)
              .margin({ right: 12 })
              .onClick(() => { this.openDrawer() })
          } else {
            Text('👤')
              .fontSize(22)
              .margin({ right: 12 })
              .onClick(() => { this.openDrawer() })
          }

          Text('锤子铺')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.TEXT_PRIMARY)

          Blank()

          // 发布入口
          Text('发布')
            .fontSize(14)
            .fontColor(Colors.PRIMARY)
            .margin({ right: 16 })
            .onClick(() => {
              router.pushUrl({ url: Constants.PAGE_PRODUCT_PUBLISH })
            })

          // 搜索
          Text('🔍')
            .fontSize(22)
            .onClick(() => router.pushUrl({ url: Constants.PAGE_SEARCH }))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .backgroundColor(Colors.BG_WHITE)

        // 分类 chip 横滚
        Scroll() {
          Row() {
            ForEach(this.categories, (cat: Category) => {
              Text(cat.icon + ' ' + cat.name)
                .fontSize(12)
                .fontColor(Colors.TEXT_SECONDARY)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(14)
                .border({ width: 1, color: Colors.DIVIDER })
                .margin({ right: 8 })
                .backgroundColor(Colors.BG_WHITE)
                .onClick(() => {
                  router.pushUrl({
                    url: Constants.PAGE_PRODUCT_LIST,
                    params: { categoryId: cat.id, categoryName: cat.name }
                  })
                })
            })
          }
          .padding({ left: 16, right: 16, top: 4, bottom: 4 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(40)
        .backgroundColor(Colors.BG_WHITE)
        .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })

        // Feed 列表
        if (this.feedProducts.length === 0 && !this.feedLoading) {
          Column() {
            Text('暂无内容')
              .fontSize(16)
              .fontColor(Colors.TEXT_HINT)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Refresh({ refreshing: $$this.feedRefreshing }) {
            List() {
              ForEach(this.feedProducts, (product: Product) => {
                ListItem() {
                  this.FeedCard(product)
                }
                .width('100%')
              })
            }
            .width('100%')
            .height('100%')
            .padding({ left: 16, right: 16 })
            .scrollBar(BarState.Off)
          }
          .layoutWeight(1)
          .onRefreshing(() => {
            this.feedRefreshing = true
            this.loadFeedData().then(() => {
              this.feedRefreshing = false
            })
          })
        }

        if (this.feedLoading) {
          LoadingProgress()
            .width(28)
            .height(28)
            .color(Colors.PRIMARY)
            .margin({ top: 8, bottom: 12 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.BG_PAPER)

      // 侧边栏遮罩 + 面板
      if (this.showSideBar) {
        // 半透明遮罩（点击关闭）
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#55000000')
          .onClick(() => { this.closeDrawer() })

        // 侧边栏面板（从左侧滑入）
        Column() {
          Scroll() {
            Column() {
              // 用户信息区
              Row() {
                if (this.userAvatar) {
                  Image(this.userAvatar)
                    .width(56)
                    .height(56)
                    .borderRadius(28)
                    .objectFit(ImageFit.Cover)
                } else {
                  Text(this.userName.charAt(0))
                    .fontSize(24)
                    .fontColor(Colors.BG_WHITE)
                    .width(56)
                    .height(56)
                    .borderRadius(28)
                    .backgroundColor(Colors.PRIMARY)
                    .textAlign(TextAlign.Center)
                    .lineHeight(56)
                }

                Column() {
                  Text(this.userName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Colors.TEXT_PRIMARY)

                  Text(this.userPhone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                    .fontSize(12)
                    .fontColor(Colors.TEXT_SECONDARY)
                    .margin({ top: 4 })
                }
                .margin({ left: 12 })
                .alignItems(HorizontalAlign.Start)

                Blank()

                Text('编辑 >')
                  .fontSize(12)
                  .fontColor(Colors.TEXT_HINT)
                  .onClick(() => {
                    this.closeDrawer()
                    router.pushUrl({ url: Constants.PAGE_PROFILE_EDIT })
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 40, bottom: 20 })
              .backgroundColor(Colors.BG_WHITE)

              // 统计数据
              Row() {
                this.StatItem('收藏', `${this.userCollectCount}`, () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_PRODUCT_LIST })
                })
                this.StatItem('关注', `${this.userFollowCount}`, () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_ARTISAN_LIST })
                })
                this.StatItem('订单', `${this.userOrderCount}`, () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_ORDER_LIST })
                })
              }
              .width('100%')
              .padding({ top: 16, bottom: 16 })
              .backgroundColor(Colors.BG_WHITE)
              .margin({ top: 1 })

              // 菜单列表
              Column() {
                this.MenuItem('🛒', `购物车 (${this.cartCount})`, () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_CART })
                })
                this.MenuItem('📦', '发布作品', () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_PRODUCT_PUBLISH })
                })
                this.MenuItem('📋', '我的订单', () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_ORDER_LIST })
                })
                this.MenuItem('📍', '收货地址', () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_ADDRESS_LIST })
                })
                this.MenuItem('❤️', '我的收藏', () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_PRODUCT_LIST })
                })
                this.MenuItem('🧑‍🎨', '关注的匠人', () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_ARTISAN_LIST })
                })
                this.MenuItem('🔔', '消息通知', () => {
                  this.closeDrawer()
                })
                this.MenuItem('⚙️', '设置', () => {
                  this.closeDrawer()
                })
              }
              .width('100%')
              .backgroundColor(Colors.BG_WHITE)
              .margin({ top: 1 })

              Row().height(20)
            }
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
        }
        .width('78%')
        .height('100%')
        .backgroundColor(Colors.BG_PAPER)
        .offset({ x: `${this.drawerOffset}%` })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatItem(label: string, count: string, onClick?: () => void) {
    Column() {
      Text(count)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.TEXT_PRIMARY)
      Text(label)
        .fontSize(12)
        .fontColor(Colors.TEXT_SECONDARY)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .onClick(() => {
      if (onClick) { onClick() }
    })
  }

  @Builder
  MenuItem(icon: string, title: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(20)
        .margin({ right: 12 })

      Text(title)
        .fontSize(15)
        .fontColor(Colors.TEXT_PRIMARY)
        .layoutWeight(1)

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(14)
        .height(14)
        .fillColor(Colors.TEXT_HINT)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(onClick)
  }

  // Feed 卡片（无价格，突出文化内容）
  @Builder
  FeedCard(product: Product) {
    Column() {
      Image(product.images[0])
        .width('100%')
        .height(200)
        .objectFit(ImageFit.Cover)

      Text(product.name)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.TEXT_PRIMARY)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 10 })

      Row() {
        Text(product.artisanName)
          .fontSize(12)
          .fontColor(Colors.TEXT_SECONDARY)

        Blank()

        Text(product.craftType)
          .fontSize(11)
          .fontColor(Colors.PRIMARY)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(4)
          .backgroundColor(Colors.PRIMARY_BG)
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(12)
    .borderRadius(8)
    .backgroundColor(Colors.BG_WHITE)
    .margin({ top: 10 })
    .onClick(() => {
      router.pushUrl({ url: Constants.PAGE_PRODUCT_DETAIL, params: { productId: product.id } })
    })
  }
}
