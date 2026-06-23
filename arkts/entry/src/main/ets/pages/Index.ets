// 主页 — 底部Tab导航 + 首页内容
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Product } from '../model/Product'
import { Artisan } from '../model/Artisan'
import { Category } from '../model/Category'
import { BannerItem, Banner } from '../components/Banner'
import { SearchBar } from '../components/SearchBar'
import { ProductCard } from '../components/ProductCard'
import { ArtisanCard } from '../components/ArtisanCard'
import { ProductService } from '../service/ProductService'
import { CartService } from '../service/CartService'
import { ApiClient } from '../service/ApiClient'
import { MockCategories } from '../mock/MockCategories'
import { getHotArtisans } from '../mock/MockArtisans'
import { User } from '../model/User'

@Entry
@Component
struct Index {
  @State currentTab: number = 0
  @State cartCount: number = CartService.getCartCount()

  // 首页数据
  @State banners: BannerItem[] = [
    {
      image: 'https://picsum.photos/seed/banner01/750/320',
      title: '匠心传承 · 非遗好物季',
      productId: 'p001'
    },
    {
      image: 'https://picsum.photos/seed/banner02/750/320',
      title: '遇见手艺 · 匠人故事',
      productId: 'p002'
    },
    {
      image: 'https://picsum.photos/seed/banner03/750/320',
      title: '新中式生活美学专场',
      productId: 'p004'
    }
  ]
  @State hotArtisans: Artisan[] = getHotArtisans()
  @State recommendProducts: Product[] = []
  @State loading: boolean = true
  @State userName: string = '非遗爱好者'
  @State userAvatar: string = ''
  @State userPhone: string = ''
  @State userCollectCount: number = 0
  @State userFollowCount: number = 0
  @State userOrderCount: number = 0

  private tabTitles: string[] = ['首页', '分类', '百科', '购物车', '我的']
  private tabIcons: string[] = ['🏠', '📂', '📚', '🛒', '👤']

  aboutToAppear(): void {
    this.loadRecommendProducts()
    this.loadUserData()
  }

  async loadRecommendProducts(): Promise<void> {
    const resp = await ProductService.fetchRecommendProducts()
    if (resp.code === 0) {
      this.recommendProducts = resp.data
    }
    this.loading = false
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

  onPageShow(): void {
    this.cartCount = CartService.getCartCount()
    this.loadUserData()
  }

  build() {
    Tabs({ index: this.currentTab }) {
      // Tab 0: 首页
      TabContent() {
        this.HomeContent()
      }.tabBar(this.TabBar(0))

      // Tab 1: 分类
      TabContent() {
        this.CategoryContent()
      }.tabBar(this.TabBar(1))

      // Tab 2: 非遗百科
      TabContent() {
        this.WikiContent()
      }.tabBar(this.TabBar(2))

      // Tab 3: 购物车
      TabContent() {
        this.CartContent()
      }.tabBar(this.TabBar(3))

      // Tab 4: 我的
      TabContent() {
        this.ProfileContent()
      }.tabBar(this.TabBar(4))
    }
    .barHeight(56)
    .barPosition(BarPosition.End)
    .onChange((index: number) => {
      this.currentTab = index
    })
  }

  @Builder
  TabBar(index: number) {
    Column() {
      Text(this.tabIcons[index])
        .fontSize(22)
      Text(this.tabTitles[index])
        .fontSize(10)
        .margin({ top: 2 })
        .fontColor(this.currentTab === index ? Colors.PRIMARY : Colors.TEXT_HINT)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // ============ 首页内容 ============
  @Builder
  HomeContent() {
    Scroll() {
      Column() {
        // 搜索栏
        SearchBar({
          placeholder: '搜非遗好物、匠人、技艺...',
          onTap: () => router.pushUrl({ url: Constants.PAGE_SEARCH })
        })

        // Banner 轮播
        Banner({
          banners: this.banners,
          onItemClick: (item: BannerItem) => {
            if (item.productId) {
              router.pushUrl({ url: Constants.PAGE_PRODUCT_DETAIL, params: { productId: item.productId } })
            }
          }
        })

        // 分类入口
        this.CategoryGrid()

        // 热门匠人推荐
        this.HotArtisanSection()

        // 推荐商品
        this.RecommendSection()

        // 底部安全区
        Row().height(16)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PAPER)
    .scrollBar(BarState.Off)
  }

  // 分类入口网格
  @Builder
  CategoryGrid() {
    Column() {
      Row() {
        Text('非遗分类')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      Grid() {
        ForEach(MockCategories, (cat: Category) => {
          GridItem() {
            Column() {
              Text(cat.icon)
                .fontSize(28)
              Text(cat.name)
                .fontSize(11)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ top: 4 })
            }
            .width('100%')
            .padding({ top: 10, bottom: 10 })
            .borderRadius(8)
            .backgroundColor(Colors.BG_CARD)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsGap(10)
      .columnsGap(10)
      .width('100%')
      .padding({ left: 16, right: 16 })
      .height(180)
    }
    .margin({ top: 8 })
  }

  // 热门匠人推荐
  @Builder
  HotArtisanSection() {
    Column() {
      Row() {
        Text('热门匠人')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.TEXT_PRIMARY)

        Blank()

        Text('更多 >')
          .fontSize(12)
          .fontColor(Colors.TEXT_HINT)
          .onClick(() => router.pushUrl({ url: Constants.PAGE_ARTISAN_LIST }))
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ top: 20, bottom: 10 })

      Row() {
        ForEach(this.hotArtisans, (artisan: Artisan) => {
          ArtisanCard({
            artisan: artisan,
            onItemClick: (a: Artisan) => {
              router.pushUrl({ url: Constants.PAGE_ARTISAN_DETAIL, params: { artisanId: a.id } })
            }
          })
        })
      }
      .padding({ left: 16, right: 16 })
    }
  }

  // 推荐商品列表
  @Builder
  RecommendSection() {
    Column() {
      Row() {
        Text('为你推荐')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.TEXT_PRIMARY)

        Blank()

        Text('更多 >')
          .fontSize(12)
          .fontColor(Colors.TEXT_HINT)
          .onClick(() => router.pushUrl({ url: Constants.PAGE_PRODUCT_LIST }))
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ top: 20, bottom: 10 })

      if (this.loading) {
        Row() {
          LoadingProgress().width(24).height(24).color(Colors.PRIMARY)
          Text('正在加载...').fontSize(14).fontColor(Colors.TEXT_HINT).margin({ left: 8 })
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.Center)
      } else if (this.recommendProducts.length === 0) {
        Text('暂无推荐商品')
          .fontSize(13)
          .fontColor(Colors.TEXT_HINT)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 30, bottom: 30 })
      } else {
        Grid() {
          ForEach(this.recommendProducts, (product: Product) => {
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
        .padding({ left: 16, right: 16 })
      }
    }
  }

  // ============ 分类 Tab ============
  @Builder
  CategoryContent() {
    Scroll() {
      Column() {
        ForEach(MockCategories, (cat: Category) => {
          Row() {
            Text(cat.icon)
              .fontSize(28)
              .margin({ right: 12 })

            Text(cat.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.TEXT_PRIMARY)
              .layoutWeight(1)

            if (cat.children && cat.children.length > 0) {
              Row() {
                ForEach(cat.children, (sub: Category) => {
                  Text(sub.name)
                    .fontSize(11)
                    .fontColor(Colors.TEXT_SECONDARY)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(12)
                    .backgroundColor(Colors.PRIMARY_BG)
                    .margin({ left: 6 })
                })
              }
            }

            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(16)
              .height(16)
              .fillColor(Colors.TEXT_HINT)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 14, bottom: 14 })
          .borderRadius(8)
          .backgroundColor(Colors.BG_CARD)
          .margin({ left: 16, right: 16, top: 6, bottom: 6 })
          .onClick(() => {
            router.pushUrl({ url: Constants.PAGE_PRODUCT_LIST, params: { categoryId: cat.id, categoryName: cat.name } })
          })
        })

        Row().height(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PAPER)
    .scrollBar(BarState.Off)
  }

  // ============ 非遗百科 Tab ============
  @Builder
  WikiContent() {
    Column() {
      Text('非遗百科')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.TEXT_PRIMARY)
        .width('100%')
        .padding({ left: 16, top: 16, bottom: 8 })
        .backgroundColor(Colors.BG_PAPER)

      Scroll() {
        Column() {
          this.WikiCard('什么是非物质文化遗产？', '中国非物质文化遗产是指各族人民世代相传并视为其文化遗产组成部分的各种传统文化表现形式，以及与传统文化表现形式相关的实物和场所。', 'https://picsum.photos/seed/wiki01/750/300')

          this.WikiCard('十大类别', '我国非遗分为十大类别：传统技艺、传统美术、传统医药、民俗、传统戏剧、传统音乐、传统舞蹈、曲艺、传统体育游艺与杂技、民间文学。', 'https://picsum.photos/seed/wiki02/750/300')

          this.WikiCard('传承人制度', '非遗传承人是指直接参与非物质文化遗产传承，且具有公认的代表性、权威性和影响力的传承者，分为县级、省级、国家级三个等级。', 'https://picsum.photos/seed/wiki03/750/300')

          this.WikiCard('保护与创新', '在保护非遗文化核心价值的同时，通过与现代设计、时尚、科技融合，让非遗走入现代生活，焕发新的生命力。', 'https://picsum.photos/seed/wiki04/750/300')

          Row().height(16)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Colors.BG_PAPER)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PAPER)
  }

  @Builder
  WikiCard(title: string, desc: string, image: string) {
    Column() {
      Image(image)
        .width('100%')
        .height(150)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 8, topRight: 8 })

      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.TEXT_PRIMARY)
          .width('100%')

        Text(desc)
          .fontSize(13)
          .fontColor(Colors.TEXT_SECONDARY)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 8 })
          .lineHeight(20)
      }
      .width('100%')
      .padding(14)
    }
    .width('100%')
    .borderRadius(8)
    .backgroundColor(Colors.BG_CARD)
    .margin({ left: 16, right: 16, top: 10 })
  }

  // ============ 购物车 Tab ============
  @Builder
  CartContent() {
    Column() {
      Text('购物车')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.TEXT_PRIMARY)
        .width('100%')
        .padding({ left: 16, top: 16, bottom: 8 })
        .backgroundColor(Colors.BG_PAPER)

      Scroll() {
        Column() {
          Row() {
            Image('https://picsum.photos/seed/nh07/80/80')
              .width(80)
              .height(80)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)

            Column() {
              Text('苗族银饰錾花手镯 · 百鸟朝凤')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.TEXT_PRIMARY)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text('杨阿妹')
                .fontSize(11)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ top: 4 })

              Row() {
                Text('¥560.00')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.PRIMARY)

                Blank()

                Row() {
                  Text('-').fontSize(18).fontColor(Colors.TEXT_PRIMARY).width(28).textAlign(TextAlign.Center)
                  Text('1').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(36).textAlign(TextAlign.Center)
                  Text('+').fontSize(18).fontColor(Colors.TEXT_PRIMARY).width(28).textAlign(TextAlign.Center)
                }
                .borderRadius(4)
                .border({ width: 1, color: Colors.DIVIDER })
              }
              .width('100%')
              .margin({ top: 8 })
            }
            .layoutWeight(1)
            .margin({ left: 10 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(12)
          .borderRadius(8)
          .backgroundColor(Colors.BG_CARD)
          .margin({ left: 16, right: 16, top: 10 })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Colors.BG_PAPER)

      // 底部结算栏
      Row() {
        Text('合计: ')
          .fontSize(14)
          .fontColor(Colors.TEXT_PRIMARY)
        Text('¥560.00')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.PRIMARY)

        Blank()

        Button('去结算')
          .fontSize(14)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(20)
          .width(100)
          .height(36)
          .onClick(() => {
            router.pushUrl({ url: Constants.PAGE_ORDER_CONFIRM })
          })
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Colors.BG_WHITE)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PAPER)
  }

  // ============ 我的 Tab ============
  @Builder
  ProfileContent() {
    Scroll() {
      Column() {
        // 顶部用户信息区
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
              .backgroundColor(Colors.PRIMARY_LIGHT)
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
        .backgroundColor(Colors.BG_CARD)
        .borderRadius(8)
        .margin({ left: 16, right: 16, top: 20 })

        // 数据统计
        Row() {
          this.StatItem('收藏', `${this.userCollectCount}`, () => router.pushUrl({ url: Constants.PAGE_PRODUCT_LIST }))
          this.StatItem('关注', `${this.userFollowCount}`, () => router.pushUrl({ url: Constants.PAGE_ARTISAN_LIST }))
          this.StatItem('订单', `${this.userOrderCount}`, () => router.pushUrl({ url: Constants.PAGE_ORDER_LIST }))
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
        .backgroundColor(Colors.BG_CARD)
        .borderRadius(8)
        .margin({ left: 16, right: 16, top: 12 })

        // 功能菜单
        Column() {
          this.MenuItem('📦', '发布商品', () => router.pushUrl({ url: Constants.PAGE_PRODUCT_PUBLISH }))
          this.MenuItem('📋', '我的订单', () => router.pushUrl({ url: Constants.PAGE_ORDER_LIST }))
          this.MenuItem('📍', '收货地址', () => router.pushUrl({ url: Constants.PAGE_ADDRESS_LIST }))
          this.MenuItem('❤️', '我的收藏', () => router.pushUrl({ url: Constants.PAGE_PRODUCT_LIST }))
          this.MenuItem('🧑‍🎨', '关注的匠人', () => router.pushUrl({ url: Constants.PAGE_ARTISAN_LIST }))
          this.MenuItem('🔔', '消息通知', () => {})
          this.MenuItem('⚙️', '设置', () => {})
        }
        .width('100%')
        .backgroundColor(Colors.BG_CARD)
        .borderRadius(8)
        .margin({ left: 16, right: 16, top: 12 })

        Row().height(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PAPER)
    .scrollBar(BarState.Off)
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
