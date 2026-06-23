// SKU 规格选择器
import { Sku } from '../model/Product'
import { Colors } from '../common/Colors'
import { Utils } from '../common/Utils'

@Component
export struct SkuSelector {
  @Prop skus: Sku[] = []
  @Prop selectedSkuId: string = ''
  onSelect?: (sku: Sku) => void

  build() {
    Column() {
      Text('选择规格')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.TEXT_PRIMARY)
        .width('100%')
        .padding({ left: 20, top: 20, bottom: 12 })

      Scroll() {
        Row() {
          ForEach(this.skus, (sku: Sku) => {
            Column() {
              Image(sku.image)
                .width(60)
                .height(60)
                .objectFit(ImageFit.Cover)
                .borderRadius(6)

              Text(sku.name)
                .fontSize(12)
                .fontColor(Colors.TEXT_PRIMARY)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width(80)
                .textAlign(TextAlign.Center)
                .margin({ top: 4 })

              Text(Utils.formatPrice(sku.price))
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(Colors.PRIMARY)
                .margin({ top: 2 })

              if (sku.stock === 0) {
                Text('已售罄')
                  .fontSize(10)
                  .fontColor(Colors.TEXT_HINT)
              }
            }
            .width(100)
            .padding(8)
            .borderRadius(8)
            .border({
              width: sku.id === this.selectedSkuId ? 2 : 1,
              color: sku.id === this.selectedSkuId ? Colors.PRIMARY : Colors.DIVIDER
            })
            .backgroundColor(sku.id === this.selectedSkuId ? Colors.PRIMARY_BG : Colors.BG_WHITE)
            .margin({ right: 12 })
            .opacity(sku.stock === 0 ? 0.4 : 1)
            .onClick(() => {
              if (sku.stock > 0 && this.onSelect) {
                this.onSelect(sku)
              }
            })
          })
        }
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .backgroundColor(Colors.BG_CARD)
  }
}
