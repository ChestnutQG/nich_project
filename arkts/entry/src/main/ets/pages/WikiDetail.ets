// 非遗百科详情页（占位页面）
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { NavBar } from '../components/NavBar'

@Entry
@Component
struct WikiDetail {
  @State title: string = '百科详情'
  @State content: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    if (params) {
      this.title = params['title'] ?? '百科详情'
    }
  }

  build() {
    Column() {
      NavBar({ title: this.title, showBack: true })

      Scroll() {
        Column() {
          Image('https://picsum.photos/seed/wiki01/750/350')
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)

          Column() {
            Text(this.title)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.TEXT_PRIMARY)
              .width('100%')

            Text('非物质文化遗产是中华优秀传统文化的重要组成部分，是中华文明绵延传承的生动见证。保护好、传承好、利用好非物质文化遗产，对于延续历史文脉、坚定文化自信、推动文明交流互鉴、建设社会主义文化强国具有重要意义。')
              .fontSize(14)
              .fontColor(Colors.TEXT_SECONDARY)
              .lineHeight(24)
              .width('100%')
              .margin({ top: 16 })
          }
          .width('100%')
          .padding(16)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Colors.BG_PAPER)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
