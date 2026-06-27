// 我的收藏页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Product } from '../model/Product'
import { FavoriteService } from '../service/FavoriteService'
import { NavBar } from '../components/NavBar'
import { ProductCard } from '../components/ProductCard'

@Entry
@Component
struct FavoriteList {
  @State products: Product[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    this.loadFavorites()
  }

  onPageShow(): void {
    // 从详情页取消收藏后返回时刷新
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
      NavBar({ title: '我的收藏', showBack: true })

      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(Colors.PRIMARY)
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.products.length === 0) {
        Column() {
          Text('🤍').fontSize(48).opacity(0.6)
          Text('还没有收藏的作品').fontSize(14).fontColor(Colors.TEXT_HINT).margin({ top: 8 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
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
            .padding({ left: 16, right: 16, top: 12, bottom: 16 })
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
