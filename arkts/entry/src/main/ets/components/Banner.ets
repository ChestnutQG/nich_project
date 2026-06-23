// 轮播 Banner 组件
import { Colors } from '../common/Colors'

export interface BannerItem {
  image: string
  title: string
  productId?: string
}

@Component
export struct Banner {
  @Prop banners: BannerItem[] = []
  onItemClick?: (item: BannerItem) => void

  build() {
    Swiper() {
      ForEach(this.banners, (item: BannerItem) => {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(item.image)
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)

          // 底部渐变遮罩
          Row()
            .width('100%')
            .height(48)
            .borderRadius({ bottomLeft: 12, bottomRight: 12 })
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['#00000000', 0], ['#00000088', 1]]
            })
            .position({ bottom: 0 })

          Text(item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .padding({ left: 16, bottom: 12 })
        }
        .onClick(() => {
          if (this.onItemClick) {
            this.onItemClick(item)
          }
        })
      }, (item: BannerItem) => item.image)
    }
    .autoPlay(true)
    .interval(4000)
    .indicator(
      new DotIndicator()
        .color(Colors.TEXT_HINT)
        .selectedColor(Colors.PRIMARY)
    )
    .loop(true)
    .width('100%')
    .height(160)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 8, bottom: 16 })
  }
}
