// 我的 — 独立页面（从首页顶部头像图标进入）
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { CartService } from '../service/CartService'
import { AuthService } from '../service/AuthService'
import { ensureTokenLoaded } from '../service/ApiClient'
import { User } from '../model/User'
import { MessageService } from '../service/MessageService'
import { NotificationService } from '../service/NotificationService'
import { NavBar } from '../components/NavBar'
import { SettingsService } from '../service/SettingsService'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct Profile {
  @State cartCount: number = CartService.getCartCount()
  @State user: User | null = null
  @State userName: string = '未登录'
  @State userAvatar: string = ''
  @State userPhone: string = ''
  @State userRole: string = ''
  @State userCredit: number = 100
  @State userCollectCount: number = 0
  @State userFollowCount: number = 0
  @State userOrderCount: number = 0
  @State unreadMsgCount: number = 0
  private pollTimer: number = -1

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
    this.loadUserData()
    CartService.loadCartCount().then((c: number) => { this.cartCount = c })
    this.loadUnreadCount()
    this.startPolling()
    SettingsService.ensureInit()
  }

  onPageShow(): void {
    this.loadUnreadCount()
    this.startPolling()
  }

  onPageHide(): void {
    this.stopPolling()
  }

  startPolling(): void {
    if (this.pollTimer !== -1) return
    this.pollTimer = setInterval(() => {
      this.loadUnreadCount()
    }, 30000)
  }

  stopPolling(): void {
    if (this.pollTimer !== -1) {
      clearInterval(this.pollTimer)
      this.pollTimer = -1
    }
  }

  async loadUserData(): Promise<void> {
    await ensureTokenLoaded()
    const resp = await AuthService.getUserInfo()
    if (resp.code === 0 && resp.data) {
      const u = resp.data
      this.user = u
      this.userName = u.nickname || this.t('用户', 'User')
      this.userAvatar = u.avatar || ''
      this.userPhone = u.phone || ''
      this.userRole = u.role || 'user'
      this.userCredit = u.creditScore || 100
      this.userCollectCount = u.collectCount || 0
      this.userFollowCount = u.followCount || 0
      this.userOrderCount = u.orderCount || 0
    } else {
      this.user = null
      this.resetUserState()
      router.pushUrl({ url: Constants.PAGE_LOGIN })
    }
  }

  async loadUnreadCount(): Promise<void> {
    const n = await NotificationService.unreadCount()
    const m = await MessageService.unreadCount()
    this.unreadMsgCount = n + m
  }

  private resetUserState(): void {
    this.userName = this.t('未登录', 'Not logged in')
    this.userAvatar = ''
    this.userPhone = ''
    this.userRole = ''
    this.userCredit = 100
    this.userCollectCount = 0
    this.userFollowCount = 0
    this.userOrderCount = 0
  }

  build() {
    Column() {
      NavBar({ title: this.t('我的', 'Profile'), showBack: true })

      Scroll() {
        Column() {
          // 用户信息卡片
          Row() {
            if (this.userAvatar) {
              Image(this.userAvatar)
                .width(56)
                .height(56)
                .borderRadius(28)
                .objectFit(ImageFit.Cover)
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
            }

            Column() {
              Row() {
                Text(this.userName)
                  .fontSize(this.fs(16))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.textPrimary(this.theme))
                Text(this.roleLabel())
                  .fontSize(this.fs(10))
                  .fontColor(Theme.WHITE)
                  .backgroundColor(this.userRole === 'admin' ? Theme.error(this.theme) :
                    this.userRole === 'artisan' ? Theme.gold(this.theme) : Theme.primary(this.theme))
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ left: 8 })
              }

              Text(this.userPhone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                .fontSize(this.fs(12))
                .fontColor(Theme.textSecondary(this.theme))
                .margin({ top: 4 })

              Text(`${this.t('信用分', 'Credit')}: ${this.userCredit}`)
                .fontSize(this.fs(11))
                .fontColor(this.userCredit >= 80 ? Theme.success(this.theme) :
                  this.userCredit >= 60 ? Theme.warning(this.theme) : Theme.error(this.theme))
                .margin({ top: 2 })
            }
            .margin({ left: 12 })
            .alignItems(HorizontalAlign.Start)

            Blank()

            Text(this.t('编辑资料 >', 'Edit >'))
              .fontSize(this.fs(12))
              .fontColor(Theme.textHint(this.theme))
              .onClick(() => router.pushUrl({ url: Constants.PAGE_PROFILE_EDIT }))
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Theme.card(this.theme))
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 20 })

          // 统计数据
          Row() {
            this.StatItem(this.t('收藏', 'Saved'), `${this.userCollectCount}`)
            this.StatItem(this.t('关注', 'Following'), `${this.userFollowCount}`)
            this.StatItem(this.t('订单', 'Orders'), `${this.userOrderCount}`)
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(Theme.card(this.theme))
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 12 })

          // 菜单列表
          Column() {
            this.MenuItem('🛒', `${this.t('购物车', 'Cart')} (${this.cartCount})`, () => {
              router.pushUrl({ url: Constants.PAGE_CART })
            })
            this.MenuItem('📦', this.t('发布作品', 'Publish'), () => router.pushUrl({ url: Constants.PAGE_PRODUCT_PUBLISH }))
            this.MenuItem('📋', this.t('我的订单', 'My Orders'), () => router.pushUrl({ url: Constants.PAGE_ORDER_LIST }))
            this.MenuItem('⚖️', this.t('我的维权', 'My Disputes'), () => router.pushUrl({ url: Constants.PAGE_DISPUTE_LIST }))
            this.MenuItem('👨‍⚖️', this.t('陪审邀请', 'Jury'), () => router.pushUrl({ url: Constants.PAGE_JURY_INVITATIONS }))
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
                Row()
                  .width(9)
                  .height(9)
                  .borderRadius(5)
                  .backgroundColor('#E74C3C')
                  .margin({ right: 8 })
                Text(`${this.unreadMsgCount}`)
                  .fontSize(12)
                  .fontColor(Colors.BG_WHITE)
                  .backgroundColor('#E74C3C')
                  .borderRadius(10)
                  .padding({ left: 7, right: 7, top: 2, bottom: 2 })
              }

              Image($r('sys.media.ohos_ic_public_arrow_right'))
                .width(14)
                .height(14)
                .fillColor(Theme.textHint(this.theme))
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .onClick(() => {
              router.pushUrl({ url: Constants.PAGE_MESSAGE_CENTER })
            })
            this.MenuItem('📍', this.t('收货地址', 'Addresses'), () => router.pushUrl({ url: Constants.PAGE_ADDRESS_LIST }))
            this.MenuItem('❤️', this.t('我的收藏', 'Favorites'), () => router.pushUrl({ url: Constants.PAGE_FAVORITE_LIST }))
            this.MenuItem('🧑‍🎨', this.t('关注的匠人', 'Following'), () => router.pushUrl({ url: Constants.PAGE_FOLLOW_LIST }))
            this.MenuItem('⚙️', this.t('设置', 'Settings'), () => router.pushUrl({ url: Constants.PAGE_SETTINGS }))
          }
          .width('100%')
          .backgroundColor(Theme.card(this.theme))
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 12 })

          // 退出登录
          Column() {
            Row() {
              Text(this.t('退出登录', 'Sign Out'))
                .fontSize(this.fs(15))
                .fontColor(Theme.error(this.theme))
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .justifyContent(FlexAlign.Center)
            .onClick(async () => {
              await AuthService.logout()
              this.user = null
              this.resetUserState()
              promptAction.showToast({ message: this.t('已退出', 'Signed out') })
              router.back()
            })
          }
          .width('100%')
          .backgroundColor(Theme.card(this.theme))
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 12 })

          Row().height(20)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Theme.bg(this.theme))
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }

  roleLabel(): string {
    switch (this.userRole) {
      case 'admin': return this.t('管理员', 'Admin')
      case 'artisan': return this.t('传承人', 'Artisan')
      default: return this.t('用户', 'User')
    }
  }

  @Builder
  StatItem(label: string, count: string) {
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
}
