import { FeedComponent } from './FeedPage';
import { PublishComponent } from './PublishPage';
import { MineComponent } from './MinePage';

// 主页：底部Tab导航（发现/发布/我的），嵌入三个子组件
@Entry
@Component
struct MainPage {
  @State currentTab: number = 0;  // 当前选中的Tab索引

  build() {
    Tabs({ index: this.currentTab }) {
      TabContent() {
        FeedComponent()
      }.tabBar(this.TabBuilder('发现', 0))

      TabContent() {
        PublishComponent()
      }.tabBar(this.TabBuilder('发布', 1))

      TabContent() {
        MineComponent()
      }.tabBar(this.TabBuilder('我的', 2))
    }
    .width('100%').height('100%')
    .barPosition(BarPosition.End)
    .onChange((index: number) => { this.currentTab = index; })
  }

  // 底部Tab构建器：高亮当前选中标签
  @Builder TabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(13)
        .fontColor(this.currentTab === index ? '#C62828' : '#999')
    }
    .padding({ top: 4 })
  }
}
