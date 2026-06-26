// 我的 — 独立页面（从首页顶部头像图标进入）
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { CartService } from '../service/CartService'
import { ApiClient } from '../service/ApiClient'
import { User } from '../model/User'
import { NavBar } from '../components/NavBar'

@Entry
@Component
struct Profile {
  @State cartCount: number = CartService.getCartCount()
  @State userName: string = '非遗爱好者'
  @State userAvatar: string = ''
  @State userPhone: string = ''
  @State userCollectCount: number = 0
  @State userFollowCount: number = 0
  @State userOrderCount: number = 0

  aboutToAppear(): void {
    this.loadUserData()
    this.cartCount = CartService.getCartCount()
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
            this.StatItem('收藏', `${this.userCollectCount}`, () => router.pushUrl({ url: Constants.PAGE_PRODUCT_LIST }))
            this.StatItem('关注', `${this.userFollowCount}`, () => router.pushUrl({ url: Constants.PAGE_ARTISAN_LIST }))
            this.StatItem('订单', `${this.userOrderCount}`, () => router.pushUrl({ url: Constants.PAGE_ORDER_LIST }))
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
            this.MenuItem('📍', '收货地址', () => router.pushUrl({ url: Constants.PAGE_ADDRESS_LIST }))
            this.MenuItem('❤️', '我的收藏', () => router.pushUrl({ url: Constants.PAGE_PRODUCT_LIST }))
            this.MenuItem('🧑‍🎨', '关注的匠人', () => router.pushUrl({ url: Constants.PAGE_ARTISAN_LIST }))
            this.MenuItem('🔔', '消息通知', () => {})
            this.MenuItem('⚙️', '设置', () => {})
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
}
