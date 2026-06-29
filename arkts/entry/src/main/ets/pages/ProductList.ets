// 商品列表页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Product } from '../model/Product'
import { PagedData } from '../model/ApiResponse'
import { ProductService } from '../service/ProductService'
import { NavBar } from '../components/NavBar'
import { ProductCard } from '../components/ProductCard'
import { LoadingMore } from '../components/LoadingMore'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct ProductList {
  @State products: Product[] = []
  @State page: number = 1
  @State hasMore: boolean = true
  @State loading: boolean = false
  @State sortBy: string = 'default'
  private categoryId: string = ''
  private categoryName: string = '全部商品'

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
    if (params) {
      this.categoryId = params['categoryId'] ?? ''
      this.categoryName = params['categoryName'] ?? '全部商品'
    }
    this.loadProducts()
  }

  async loadProducts(): Promise<void> {
    if (this.loading) return
    this.loading = true
    const resp = await ProductService.fetchProductList(
      this.page, 10, this.categoryId || undefined, this.sortBy
    )
    if (resp.code === 0) {
      if (this.page === 1) {
        this.products = resp.data.list
      } else {
        this.products = this.products.concat(resp.data.list)
      }
      this.hasMore = this.products.length < resp.data.total
    }
    this.loading = false
  }

  build() {
    Column() {
      NavBar({ title: this.categoryName, showBack: true })

      // 排序栏
      Row() {
        this.SortTab(this.t('综合', 'Default'), 'default', 0)
        this.SortTab(this.t('销量', 'Sales'), 'sales', 1)
        this.SortTab(this.t('价格↑', 'Price↑'), 'price_asc', 2)
        this.SortTab(this.t('价格↓', 'Price↓'), 'price_desc', 3)
      }
      .width('100%')
      .height(40)
      .backgroundColor(Theme.card(this.theme))

      // 商品网格
      if (this.products.length === 0 && !this.loading) {
        Column() {
          Text('📦')
            .fontSize(this.fs(48))
            .opacity(0.6)
          Text(this.t('暂无商品', 'No products'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textHint(this.theme))
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
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
            .padding({ left: 16, right: 16, top: 12 })

            LoadingMore({ hasMore: this.hasMore, loading: this.loading })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Theme.bg(this.theme))
        .scrollBar(BarState.Off)
        .onReachEnd(() => {
          if (this.hasMore && !this.loading) {
            this.page++
            this.loadProducts()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }

  @Builder
  SortTab(label: string, sortKey: string, index: number) {
    Text(label)
      .fontSize(this.fs(13))
      .fontColor(this.sortBy === sortKey ? Theme.primary(this.theme) : Theme.textSecondary(this.theme))
      .fontWeight(this.sortBy === sortKey ? FontWeight.Medium : FontWeight.Normal)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.sortBy = sortKey
        this.page = 1
        this.loadProducts()
      })
  }
}
