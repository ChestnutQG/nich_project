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
        this.SortTab('综合', 'default', 0)
        this.SortTab('销量', 'sales', 1)
        this.SortTab('价格↑', 'price_asc', 2)
        this.SortTab('价格↓', 'price_desc', 3)
      }
      .width('100%')
      .height(40)
      .backgroundColor(Colors.BG_WHITE)

      // 商品网格
      if (this.products.length === 0 && !this.loading) {
        Column() {
          Text('📦')
            .fontSize(48)
            .opacity(0.6)
          Text('暂无商品')
            .fontSize(14)
            .fontColor(Colors.TEXT_HINT)
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Colors.BG_PAPER)
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
        .backgroundColor(Colors.BG_PAPER)
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
  }

  @Builder
  SortTab(label: string, sortKey: string, index: number) {
    Text(label)
      .fontSize(13)
      .fontColor(this.sortBy === sortKey ? Colors.PRIMARY : Colors.TEXT_SECONDARY)
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
