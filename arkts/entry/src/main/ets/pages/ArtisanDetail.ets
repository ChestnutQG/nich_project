// 匠人详情页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Artisan } from '../model/Artisan'
import { Product } from '../model/Product'
import { getArtisanById } from '../mock/MockArtisans'
import { getProductsByCategory } from '../mock/MockProducts'
import { NavBar } from '../components/NavBar'
import { ProductCard } from '../components/ProductCard'

@Entry
@Component
struct ArtisanDetail {
  @State artisan: Artisan | undefined = undefined
  @State works: Product[] = []

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    if (params && params['artisanId']) {
      this.artisan = getArtisanById(params['artisanId'])
      // 加载对应分类的作品
      if (this.artisan) {
        const all = getProductsByCategory('c001')
        this.works = all.filter(p => p.artisanId === this.artisan!.id)
        if (this.works.length === 0) {
          this.works = all.slice(0, 3)
        }
      }
    }
  }

  build() {
    Column() {
      NavBar({ title: '匠人主页', showBack: true })

      if (!this.artisan) {
        Column() {
          Text('匠人不存在').fontSize(14).fontColor(Colors.TEXT_HINT)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 个人信息头部
            Column() {
              Image(this.artisan!.avatar)
                .width(80)
                .height(80)
                .borderRadius(40)
                .objectFit(ImageFit.Cover)
                .border({ width: 3, color: Colors.GOLD })

              Text(this.artisan!.name)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.TEXT_PRIMARY)
                .margin({ top: 12 })

              Row() {
                Text(this.artisan!.title)
                  .fontSize(13)
                  .fontColor(this.artisan!.level >= 3 ? Colors.GOLD : Colors.PRIMARY)
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .borderRadius(4)
                  .backgroundColor(this.artisan!.level >= 3 ? '#FFF8E1' : Colors.PRIMARY_BG)
              }
              .margin({ top: 8 })

              Text(`${this.artisan!.craftType} · ${this.artisan!.province}${this.artisan!.city}`)
                .fontSize(13)
                .fontColor(Colors.TEXT_SECONDARY)
                .margin({ top: 8 })
            }
            .width('100%')
            .padding({ top: 24, bottom: 20 })
            .backgroundColor(Colors.BG_CARD)
            .alignItems(HorizontalAlign.Center)

            // 数据统计
            Row() {
              this.NumItem('作品', this.artisan!.worksCount)
              this.NumItem('关注', this.artisan!.followersCount)
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Colors.BG_WHITE)
            .justifyContent(FlexAlign.SpaceEvenly)

            // 个人介绍
            Column() {
              Text('匠人简介')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.TEXT_PRIMARY)
                .width('100%')

              Text(this.artisan!.intro)
                .fontSize(13)
                .fontColor(Colors.TEXT_SECONDARY)
                .lineHeight(22)
                .width('100%')
                .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Colors.BG_WHITE)
            .margin({ top: 8 })

            // 作品列表
            Column() {
              Text('在售作品')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.TEXT_PRIMARY)
                .width('100%')

              Grid() {
                ForEach(this.works, (product: Product) => {
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
              .margin({ top: 10 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Colors.BG_WHITE)
            .margin({ top: 8 })

            Row().height(80)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(Colors.BG_PAPER)
        .scrollBar(BarState.Off)

        // 底部操作栏
        Row() {
          Button(this.artisan!.isFollowed ? '已关注' : '+ 关注匠人')
            .fontSize(15)
            .backgroundColor(this.artisan!.isFollowed ? Colors.DIVIDER : Colors.PRIMARY)
            .fontColor(this.artisan!.isFollowed ? Colors.TEXT_HINT : Color.White)
            .borderRadius(24)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              this.artisan!.isFollowed = !this.artisan!.isFollowed
            })

          Button('联系匠人')
            .fontSize(15)
            .backgroundColor(Colors.BG_CARD)
            .fontColor(Colors.TEXT_PRIMARY)
            .borderRadius(24)
            .height(44)
            .layoutWeight(1)
            .margin({ left: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .backgroundColor(Colors.BG_WHITE)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  NumItem(label: string, num: number) {
    Column() {
      Text(`${num}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.TEXT_PRIMARY)
      Text(label)
        .fontSize(12)
        .fontColor(Colors.TEXT_SECONDARY)
        .margin({ top: 2 })
    }
  }
}
