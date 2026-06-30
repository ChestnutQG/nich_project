// 主页 — 非遗文化内容 Feed 流
// 顶部导航 + 分类 chip + 作品卡片
// 左上角头像点击弹出侧边栏（从左侧滑入）
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Product } from '../model/Product'
import { Category } from '../model/Category'
import { ProductService } from '../service/ProductService'
import { CartService } from '../service/CartService'
import { AuthService } from '../service/AuthService'
import { CategoryService } from '../service/CategoryService'
import { User } from '../model/User'
import { MessageService } from '../service/MessageService'
import { NotificationService } from '../service/NotificationService'
import { getToken, ensureTokenLoaded, clearToken } from '../service/ApiClient'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct Index {
  @State feedProducts: Product[] = []
  @State feedLoading: boolean = true
  @State feedRefreshing: boolean = false

  @State userId: string = ''
  @State userAvatar: string = ''
  @State userName: string = '未登录'
  @State userPhone: string = ''
  @State userCollectCount: number = 0
  @State userFollowCount: number = 0
  @State userOrderCount: number = 0
  @State cartCount: number = CartService.getCartCount()
  @State isLoggedIn: boolean = false
  @State unreadMsgCount: number = 0
  private pollTimer: number = -1

  @State showSideBar: boolean = false
  @State drawerOffset: number = -100

  @State categories: Category[] = []

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
    this.loadFeedData()
    this.loadCategories()
    this.loadUserData()
    CartService.loadCartCount().then((c: number) => { this.cartCount = c })
    this.startPolling()
  }

  onPageShow(): void {
    CartService.loadCartCount().then((c: number) => { this.cartCount = c })
    this.loadUserData()
    this.loadUnreadCount()
    this.startPolling()
  }

  onPageHide(): void {
    this.stopPolling()
    // 不主动断 WS，后台也能收推送
  }

  // 定时轮询未读数（无 WebSocket，靠轮询刷新红点）
  startPolling(): void {
    if (this.pollTimer !== -1) {
      return
    }
    this.pollTimer = setInterval(() => {
      this.loadUnreadCount()
    }, 15000) // 15 秒轮询
  }

  stopPolling(): void {
    if (this.pollTimer !== -1) {
      clearInterval(this.pollTimer)
      this.pollTimer = -1
    }
  }

  async loadCategories(): Promise<void> {
    const resp = await CategoryService.fetchCategories()
    if (resp.code === 0) {
      this.categories = resp.data
    }
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
    await ensureTokenLoaded()
    this.isLoggedIn = getToken().length > 0
    if (!this.isLoggedIn) {
      this.resetUserState()
      return
    }

    const resp = await AuthService.getUserInfo()
    if (resp.code === 0 && resp.data) {
      this.userId = `${resp.data.id}`
      this.userName = resp.data.nickname || this.t('用户', 'User')
      this.userAvatar = resp.data.avatar || ''
      this.userPhone = resp.data.phone || ''
      this.userCollectCount = resp.data.collectCount || 0
      this.userFollowCount = resp.data.followCount || 0
      this.userOrderCount = resp.data.orderCount || 0
      // 登录态确认后立即拉一次未读数
      this.loadUnreadCount()
    } else {
      await clearToken()
      this.isLoggedIn = false
      this.resetUserState()
    }
  }

  async loadUnreadCount(): Promise<void> {
    if (!this.isLoggedIn) {
      this.unreadMsgCount = 0
      return
    }
    const n = await NotificationService.unreadCount()
    const m = await MessageService.unreadCount()
    this.unreadMsgCount = n + m
  }

  private resetUserState(): void {
    this.userId = ''
    this.userName = this.t('未登录', 'Not logged in')
    this.userAvatar = ''
    this.userPhone = ''
    this.userCollectCount = 0
    this.userFollowCount = 0
    this.userOrderCount = 0
  }

  // 点侧边栏头像 → 自己的公开主页（未登录则去登录）
  private openMyProfile(): void {
    this.closeDrawer()
    if (this.isLoggedIn && this.userId) {
      router.pushUrl({ url: Constants.PAGE_USER_PROFILE, params: { userId: this.userId } })
    } else {
      router.pushUrl({ url: Constants.PAGE_LOGIN })
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
          // 头像按钮 — 未读消息红点
          Stack() {
            if (this.userAvatar) {
              Image(this.userAvatar)
                .width(28)
                .height(28)
                .borderRadius(14)
                .objectFit(ImageFit.Cover)
            } else {
              Text('👤')
                .fontSize(this.fs(22))
            }
            // 未读消息红点
            if (this.unreadMsgCount > 0) {
              Row()
                .width(10)
                .height(10)
                .borderRadius(5)
                .backgroundColor('#E74C3C')
                .border({ width: 1.5, color: Colors.BG_WHITE })
                .position({ x: 18, y: -2 })
            }
          }
          .margin({ right: 12 })
          .onClick(() => { this.openDrawer() })

          Text(this.t('锤子铺', 'Chuizhi'))
            .fontSize(this.fs(22))
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textPrimary(this.theme))

          Blank()

          Text(this.t('发布', 'Publish'))
            .fontSize(this.fs(14))
            .fontColor(Theme.primary(this.theme))
            .margin({ right: 16 })
            .onClick(() => {
              router.pushUrl({ url: Constants.PAGE_PRODUCT_PUBLISH })
            })

          Text('🔍')
            .fontSize(this.fs(22))
            .onClick(() => router.pushUrl({ url: Constants.PAGE_SEARCH }))
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .backgroundColor(Theme.card(this.theme))

        // 分类 chip 横滚
        Scroll() {
          Row() {
            ForEach(this.categories, (cat: Category) => {
              Text(cat.icon + ' ' + cat.name)
                .fontSize(this.fs(12))
                .fontColor(Theme.textSecondary(this.theme))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(14)
                .border({ width: 1, color: Theme.divider(this.theme) })
                .margin({ right: 8 })
                .backgroundColor(Theme.card(this.theme))
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
        .backgroundColor(Theme.card(this.theme))
        .border({ width: { bottom: 0.5 }, color: Theme.divider(this.theme) })

        // Feed 列表
        if (this.feedProducts.length === 0 && !this.feedLoading) {
          Column() {
            Text(this.t('暂无内容', 'No content'))
              .fontSize(this.fs(16))
              .fontColor(Theme.textHint(this.theme))
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.bg(this.theme))
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
            .color(Theme.primary(this.theme))
            .margin({ top: 8, bottom: 12 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.bg(this.theme))

      // 侧边栏遮罩 + 面板
      if (this.showSideBar) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#55000000')
          .onClick(() => { this.closeDrawer() })

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
                    .onClick(() => { this.openMyProfile() })
                } else {
                  Text(this.userName.charAt(0))
                    .fontSize(this.fs(24))
                    .fontColor(Theme.WHITE)
                    .width(56)
                    .height(56)
                    .borderRadius(28)
                    .backgroundColor(Theme.primary(this.theme))
                    .textAlign(TextAlign.Center)
                    .lineHeight(56)
                    .onClick(() => { this.openMyProfile() })
                }

                Column() {
                  Text(this.userName)
                    .fontSize(this.fs(16))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.textPrimary(this.theme))

                  Text(this.userPhone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                    .fontSize(this.fs(12))
                    .fontColor(Theme.textSecondary(this.theme))
                    .margin({ top: 4 })
                }
                .margin({ left: 12 })
                .alignItems(HorizontalAlign.Start)

                Blank()

                Text(this.t('编辑 >', 'Edit >'))
                  .fontSize(this.fs(12))
                  .fontColor(Theme.textHint(this.theme))
                  .onClick(() => {
                    this.closeDrawer()
                    router.pushUrl({ url: Constants.PAGE_PROFILE_EDIT })
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 40, bottom: 20 })
              .backgroundColor(Theme.card(this.theme))

              // 统计数据
              Row() {
                this.StatItem(this.t('收藏', 'Saved'), `${this.userCollectCount}`, () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_FAVORITE_LIST })
                })
                this.StatItem(this.t('关注', 'Following'), `${this.userFollowCount}`, () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_FOLLOW_LIST })
                })
                this.StatItem(this.t('订单', 'Orders'), `${this.userOrderCount}`, () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_ORDER_LIST })
                })
              }
              .width('100%')
              .padding({ top: 16, bottom: 16 })
              .backgroundColor(Theme.card(this.theme))
              .margin({ top: 1 })

              // 菜单列表
              Column() {
                this.MenuItem('🛒', `${this.t('购物车', 'Cart')} (${this.cartCount})`, () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_CART })
                })
                this.MenuItem('📦', this.t('发布作品', 'Publish'), () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_PRODUCT_PUBLISH })
                })
                this.MenuItem('⚖️', this.t('我的维权', 'My Disputes'), () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_DISPUTE_LIST })
                })
                this.MenuItem('👨‍⚖️', this.t('陪审邀请', 'Jury'), () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_JURY_INVITATIONS })
                })
                this.MenuItem('📍', this.t('收货地址', 'Addresses'), () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_ADDRESS_LIST })
                })
                this.MenuItem('⚙️', this.t('设置', 'Settings'), () => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_SETTINGS })
                })
                // 消息通知 — 带红点提醒
                Row() {
                  Text('🔔')
                    .fontSize(20)
                    .margin({ right: 12 })

                  Text(this.t('消息通知', 'Messages'))
                    .fontSize(this.fs(15))
                    .fontColor(Theme.textPrimary(this.theme))
                    .layoutWeight(1)

                  if (this.unreadMsgCount > 0) {
                    Text(`${this.unreadMsgCount}`)
                      .fontSize(12)
                      .fontColor(Colors.BG_WHITE)
                      .backgroundColor('#E74C3C')
                      .borderRadius(10)
                      .constraintSize({ minWidth: 18 })
                      .textAlign(TextAlign.Center)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .margin({ right: 8 })
                  }

                  Image($r('sys.media.ohos_ic_public_arrow_right'))
                    .width(14)
                    .height(14)
                    .fillColor(Theme.textHint(this.theme))
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                .onClick(() => {
                  this.closeDrawer()
                  router.pushUrl({ url: Constants.PAGE_MESSAGE_CENTER })
                })

                if (this.isLoggedIn) {
                  Row() {
                    Text(this.t('退出登录', 'Sign Out'))
                      .fontSize(this.fs(15))
                      .fontColor(Theme.error(this.theme))
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                  .justifyContent(FlexAlign.Center)
                  .onClick(async () => {
                    this.closeDrawer()
                    await AuthService.logout()
                    this.unreadMsgCount = 0
                    this.resetUserState()
                    this.isLoggedIn = false
                    promptAction.showToast({ message: this.t('已退出', 'Signed out') })
                  })
                } else {
                  Row() {
                    Text(this.t('登录 / 注册', 'Sign In / Register'))
                      .fontSize(this.fs(15))
                      .fontColor(Theme.primary(this.theme))
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    this.closeDrawer()
                    router.pushUrl({ url: Constants.PAGE_LOGIN })
                  })
                }
              }
              .width('100%')
              .backgroundColor(Theme.card(this.theme))
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
        .backgroundColor(Theme.bg(this.theme))
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
        .fontSize(this.fs(20))
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.textPrimary(this.theme))
      Text(label)
        .fontSize(this.fs(12))
        .fontColor(Theme.textSecondary(this.theme))
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
        .fontSize(this.fs(20))
        .margin({ right: 12 })

      Text(title)
        .fontSize(this.fs(15))
        .fontColor(Theme.textPrimary(this.theme))
        .layoutWeight(1)

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(14)
        .height(14)
        .fillColor(Theme.textHint(this.theme))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(onClick)
  }

  // Feed 卡片
  @Builder
  FeedCard(product: Product) {
    Column() {
      Image(product.images[0])
        .width('100%')
        .height(200)
        .objectFit(ImageFit.Cover)

      Text(product.name)
        .fontSize(this.fs(15))
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.textPrimary(this.theme))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 10 })

      Row() {
        Text(product.artisanName)
          .fontSize(this.fs(12))
          .fontColor(Theme.textSecondary(this.theme))

        Blank()

        Text(product.craftType)
          .fontSize(this.fs(11))
          .fontColor(Theme.primary(this.theme))
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(4)
          .backgroundColor(Theme.primaryBg(this.theme))
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(12)
    .borderRadius(8)
    .backgroundColor(Theme.card(this.theme))
    .margin({ top: 10 })
    .onClick(() => {
      router.pushUrl({ url: Constants.PAGE_PRODUCT_DETAIL, params: { productId: product.id } })
    })
  }
}
