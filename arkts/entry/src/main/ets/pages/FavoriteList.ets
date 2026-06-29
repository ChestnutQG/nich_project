// 我的收藏页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Product } from '../model/Product'
import { FavoriteService } from '../service/FavoriteService'
import { NavBar } from '../components/NavBar'
import { ProductCard } from '../components/ProductCard'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct FavoriteList {
  @State products: Product[] = []
  @State loading: boolean = true

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
    this.loadFavorites()
  }

  onPageShow(): void {
    this.loadFavorites()
  }

  async loadFavorites(): Promise<void> {
    this.loading = true
    const resp = await FavoriteService.fetchMyFavorites()
    if (resp.code === 0) {
      this.products = resp.data
    }
    this.loading = false
  }

  build() {
    Column() {
      NavBar({ title: this.t('我的收藏', 'My Favorites'), showBack: true })

      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Theme.primary(this.theme))
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else if (this.products.length === 0) {
        Column() {
          Text('🤍').fontSize(this.fs(48)).opacity(0.6)
          Text(this.t('还没有收藏的作品', 'No favorites yet'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textHint(this.theme))
            .margin({ top: 8 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else {
        Scroll() {
          Column() {
            Grid() {
              ForEach(this.products, (product: Product) => {
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
            .padding({ left: 16, right: 16, top: 12, bottom: 16 })
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
