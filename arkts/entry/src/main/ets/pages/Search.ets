// 搜索页 — 搜索商品 + 匠人
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Product } from '../model/Product'
import { Artisan } from '../model/Artisan'
import { ProductService } from '../service/ProductService'
import { ArtisanService } from '../service/ArtisanService'
import { NavBar } from '../components/NavBar'
import { ProductCard } from '../components/ProductCard'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct SearchPage {
  @State keyword: string = ''
  @State results: Product[] = []
  @State artisanResults: Artisan[] = []
  @State searching: boolean = false
  @State history: string[] = ['苏绣', '紫砂壶', '青花瓷', '银饰', '歙砚']
  private hotKeywords: string[] = ['景德镇陶瓷', '苏绣团扇', '宜兴紫砂', '苗银饰品', '手工宣纸', '蜡染']

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  async doSearch(): Promise<void> {
    if (this.keyword.trim().length === 0) return
    this.searching = true
    if (!this.history.includes(this.keyword)) {
      const newHistory: string[] = [this.keyword]
      this.history.forEach((h: string) => { newHistory.push(h) })
      this.history = newHistory.slice(0, 10)
    }
    // 同时搜索商品和匠人
    const results = await Promise.all([
      ProductService.searchProducts(this.keyword),
      ArtisanService.searchArtisans(this.keyword)
    ])
    const productResp = results[0]
    const artisanResp = results[1]
    if (productResp.code === 0) {
      this.results = productResp.data
    }
    if (artisanResp.code === 0) {
      this.artisanResults = artisanResp.data
    }
    this.searching = false
  }

  build() {
    Column() {
      NavBar({ title: this.t('搜索', 'Search'), showBack: true })

      Row() {
        TextInput({ placeholder: this.t('搜非遗好物、匠人、技艺...', 'Search crafts, artisans...'), text: this.keyword })
          .fontSize(this.fs(14))
          .layoutWeight(1)
          .height(38)
          .backgroundColor(Color.Transparent)
          .onChange((value: string) => { this.keyword = value })
          .onSubmit(() => { this.doSearch() })

        Text(this.t('搜索', 'Search'))
          .fontSize(this.fs(14))
          .fontColor(Theme.primary(this.theme))
          .fontWeight(FontWeight.Medium)
          .margin({ left: 8 })
          .onClick(() => { this.doSearch() })
      }
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Theme.card(this.theme))

      if (this.results.length > 0 || this.artisanResults.length > 0) {
        Scroll() {
          Column() {
            // 匠人搜索结果
            if (this.artisanResults.length > 0) {
              Text('相关匠人')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.TEXT_PRIMARY)
                .width('100%')
                .padding({ left: 16, right: 16, top: 16, bottom: 8 })

              ForEach(this.artisanResults, (artisan: Artisan) => {
                Row() {
                  if (artisan.avatar) {
                    Image(artisan.avatar)
                      .width(44)
                      .height(44)
                      .borderRadius(22)
                      .objectFit(ImageFit.Cover)
                  } else {
                    Text(artisan.name.charAt(0))
                      .fontSize(18)
                      .fontColor(Colors.BG_WHITE)
                      .width(44)
                      .height(44)
                      .borderRadius(22)
                      .backgroundColor(Colors.PRIMARY)
                      .textAlign(TextAlign.Center)
                      .lineHeight(44)
                  }

                  Column() {
                    Text(artisan.name)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Colors.TEXT_PRIMARY)
                    Text(`${artisan.craftType} · ${artisan.title}`)
                      .fontSize(12)
                      .fontColor(Colors.TEXT_SECONDARY)
                      .margin({ top: 2 })
                  }
                  .margin({ left: 10 })
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text(`${artisan.followersCount} 关注`)
                    .fontSize(11)
                    .fontColor(Colors.TEXT_HINT)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .backgroundColor(Colors.BG_WHITE)
                .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })
                .onClick(() => {
                  router.pushUrl({
                    url: Constants.PAGE_ARTISAN_DETAIL,
                    params: { artisanId: artisan.id }
                  })
                })
              })
            }

            // 商品搜索结果
            if (this.results.length > 0) {
              Text(this.artisanResults.length > 0 ? '相关商品' : '搜索结果')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.TEXT_PRIMARY)
                .width('100%')
                .padding({ left: 16, right: 16, top: 16, bottom: 8 })

              Grid() {
                ForEach(this.results, (product: Product) => {
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
              .padding({ left: 16, right: 16, bottom: 16 })
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Theme.bg(this.theme))
        .scrollBar(BarState.Off)
      } else if (this.searching) {
        Row() {
          LoadingProgress().width(24).height(24).color(Theme.primary(this.theme))
          Text(this.t('搜索中...', 'Searching...')).fontSize(this.fs(14)).fontColor(Theme.textHint(this.theme)).margin({ left: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.bg(this.theme))
      } else {
        Scroll() {
          Column() {
            Row() {
              Text(this.t('搜索历史', 'History'))
                .fontSize(this.fs(14))
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.textPrimary(this.theme))
              Blank()
              Text(this.t('清空', 'Clear'))
                .fontSize(this.fs(12))
                .fontColor(Theme.textHint(this.theme))
                .onClick(() => { this.history = [] })
            }
            .width('100%')
            .padding(16)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.history, (item: string) => {
                Text(item)
                  .fontSize(this.fs(12))
                  .fontColor(Theme.textSecondary(this.theme))
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(14)
                  .backgroundColor(Theme.card(this.theme))
                  .margin({ right: 10, bottom: 10 })
                  .onClick(() => {
                    this.keyword = item
                    this.doSearch()
                  })
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

            Row() {
              Text(this.t('热门搜索', 'Hot Searches'))
                .fontSize(this.fs(14))
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.textPrimary(this.theme))
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 20 })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.hotKeywords, (item: string) => {
                Text(item)
                  .fontSize(this.fs(12))
                  .fontColor(Theme.textHint(this.theme))
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(14)
                  .backgroundColor(Theme.card(this.theme))
                  .margin({ right: 10, bottom: 10 })
                  .onClick(() => {
                    this.keyword = item
                    this.doSearch()
                  })
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
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
