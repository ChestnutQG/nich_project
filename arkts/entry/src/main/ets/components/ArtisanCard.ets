// 匠人卡片组件
import { Artisan } from '../model/Artisan'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { Utils } from '../common/Utils'

@Component
export struct ArtisanCard {
  @Prop artisan: Artisan
  onItemClick?: (artisan: Artisan) => void

  build() {
    Column() {
      // 头像
      Image(this.artisan.avatar)
        .width(64)
        .height(64)
        .borderRadius(32)
        .objectFit(ImageFit.Cover)
        .border({ width: 2, color: Colors.GOLD })

      // 姓名
      Text(this.artisan.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.TEXT_PRIMARY)
        .margin({ top: 8 })
        .maxLines(1)

      // 头衔
      Text(this.artisan.title)
        .fontSize(10)
        .fontColor(this.artisan.level >= 3 ? Colors.GOLD : Colors.TEXT_SECONDARY)
        .margin({ top: 2 })
        .maxLines(1)

      // 关注数
      Text(`${Utils.formatCount(this.artisan.followersCount)} 人关注`)
        .fontSize(10)
        .fontColor(Colors.TEXT_HINT)
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .width(96)
    .padding({ top: 12, bottom: 12, left: 6, right: 6 })
    .borderRadius(8)
    .backgroundColor(Colors.BG_CARD)
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.artisan)
      }
    })
  }
}
