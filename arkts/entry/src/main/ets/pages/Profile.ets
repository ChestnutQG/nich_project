// 我的 — 独立页面（从首页顶部头像图标进入）
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { CartService } from '../service/CartService'
import { AuthService } from '../service/AuthService'
import { ensureTokenLoaded } from '../service/ApiClient'
import { User } from '../model/User'
import { NavBar } from '../components/NavBar'

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

  aboutToAppear(): void {
    this.loadUserData()
    CartService.loadCartCount().then((c: number) => { this.cartCount = c })
  }

  async loadUserData(): Promise<void> {
    await ensureTokenLoaded()
    const resp = await AuthService.getUserInfo()
    if (resp.code === 0 && resp.data) {
      const u = resp.data
      this.user = u
      this.userName = u.nickname || '用户'
      this.userAvatar = u.avatar || ''
      this.userPhone = u.phone || ''
      this.userRole = u.role || 'user'
      this.userCredit = u.creditScore || 100
      this.userCollectCount = u.collectCount || 0
      this.userFollowCount = u.followCount || 0
      this.userOrderCount = u.orderCount || 0
    } else {
      // 未登录或 token 过期，清空状态并跳转登录
      this.user = null
      this.resetUserState()
      router.pushUrl({ url: Constants.PAGE_LOGIN })
    }
  }

  private resetUserState(): void {
    this.userName = '未登录'
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
      NavBar({ title: '我的', showBack: true })

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
              Row() {
                Text(this.userName)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                // 角色标签
                Text(this.roleLabel())
                  .fontSize(10)
                  .fontColor(Colors.BG_WHITE)
                  .backgroundColor(this.userRole === 'admin' ? '#E74C3C' :
                    this.userRole === 'artisan' ? '#C8A45C' : Colors.PRIMARY)
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ left: 8 })
              }

              Text(this.userPhone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                .fontSize(12)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ top: 4 })

              Text(`信用分: ${this.userCredit}`)
                .fontSize(11)
                .fontColor(this.userCredit >= 80 ? '#27AE60' :
                  this.userCredit >= 60 ? '#F39C12' : '#E74C3C')
                .margin({ top: 2 })
            }
            .margin({ left: 12 })
            .alignItems(HorizontalAlign.Start)

            Blank()

            Text('编辑资料 >')
              .fontSize(12)
              .fontColor(Colors.TEXT_HINT)
              .onClick(() => router.pushUrl({ url: Constants.PAGE_PROFILE_EDIT }))
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Colors.BG_WHITE)
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 20 })

          // 统计数据
          Row() {
            this.StatItem('收藏', `${this.userCollectCount}`)
            this.StatItem('关注', `${this.userFollowCount}`)
            this.StatItem('订单', `${this.userOrderCount}`)
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(Colors.BG_WHITE)
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 12 })

          // 菜单列表
          Column() {
            this.MenuItem('🛒', `购物车 (${this.cartCount})`, () => {
              router.pushUrl({ url: Constants.PAGE_CART })
            })
            this.MenuItem('📦', '发布作品', () => router.pushUrl({ url: Constants.PAGE_PRODUCT_PUBLISH }))
            this.MenuItem('📋', '我的订单', () => router.pushUrl({ url: Constants.PAGE_ORDER_LIST }))
            this.MenuItem('⚖️', '我的维权', () => router.pushUrl({ url: Constants.PAGE_DISPUTE_LIST }))
            this.MenuItem('👨‍⚖️', '陪审邀请', () => router.pushUrl({ url: Constants.PAGE_JURY_INVITATIONS }))
            this.MenuItem('📍', '收货地址', () => router.pushUrl({ url: Constants.PAGE_ADDRESS_LIST }))
            this.MenuItem('❤️', '我的收藏', () => router.pushUrl({ url: Constants.PAGE_FAVORITE_LIST }))
            this.MenuItem('🧑‍🎨', '关注的匠人', () => router.pushUrl({ url: Constants.PAGE_ARTISAN_LIST }))
          }
          .width('100%')
          .backgroundColor(Colors.BG_WHITE)
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 12 })

          // 退出登录
          Column() {
            Row() {
              Text('退出登录')
                .fontSize(15)
                .fontColor('#E74C3C')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .justifyContent(FlexAlign.Center)
            .onClick(async () => {
              await AuthService.logout()
              this.user = null
              this.resetUserState()
              promptAction.showToast({ message: '已退出' })
              router.back()
            })
          }
          .width('100%')
          .backgroundColor(Colors.BG_WHITE)
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 12 })

          Row().height(20)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Colors.BG_PAPER)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  roleLabel(): string {
    switch (this.userRole) {
      case 'admin': return '管理员'
      case 'artisan': return '传承人'
      default: return '用户'
    }
  }

  @Builder
  StatItem(label: string, count: string) {
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
}
