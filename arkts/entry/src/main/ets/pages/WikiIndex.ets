// 非遗百科首页（独立页面，用于 push 导航）
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { NavBar } from '../components/NavBar'

export interface WikiArticle {
  id: string
  title: string
  summary: string
  image: string
  category: string
}

@Entry
@Component
struct WikiIndex {
  @State articles: WikiArticle[] = [
    {
      id: 'w01',
      title: '什么是非物质文化遗产？',
      summary: '中国非物质文化遗产是各族人民世代相传并视为其文化遗产组成部分的各种传统文化表现形式，是中华文明绵延传承的生动见证。',
      image: 'https://picsum.photos/seed/wiki01/750/300',
      category: '基础知识'
    },
    {
      id: 'w02',
      title: '非遗十大类别详解',
      summary: '我国非遗分为十大类别：传统技艺、传统美术、传统医药、民俗、传统戏剧、传统音乐、传统舞蹈、曲艺、传统体育游艺与杂技、民间文学。',
      image: 'https://picsum.photos/seed/wiki02/750/300',
      category: '分类体系'
    },
    {
      id: 'w03',
      title: '非遗传承人制度',
      summary: '非遗传承人是直接参与非物质文化遗产传承的代表性人物，分为县级、省级、国家级三个等级，是活态传承的核心载体。',
      image: 'https://picsum.photos/seed/wiki03/750/300',
      category: '传承保护'
    },
    {
      id: 'w04',
      title: '当非遗遇见现代生活',
      summary: '在保护核心技艺与文化价值的前提下，非遗正与现代设计、时尚消费、数字科技深度融合，焕发全新生命力。',
      image: 'https://picsum.photos/seed/wiki04/750/300',
      category: '创新发展'
    },
    {
      id: 'w05',
      title: '苏绣：指尖上的千年绝技',
      summary: '苏绣至今已有2500余年历史，以针法精细、色彩雅致著称，2006年列入第一批国家级非物质文化遗产名录。',
      image: 'https://picsum.photos/seed/wiki05/750/300',
      category: '传统美术'
    },
    {
      id: 'w06',
      title: '景泰蓝：铜胎上的艺术传奇',
      summary: '景泰蓝又称铜胎掐丝珐琅，是集美术、工艺、雕刻、镶嵌等技艺于一体的中国传统手工艺品。',
      image: 'https://picsum.photos/seed/wiki06/750/300',
      category: '传统技艺'
    }
  ]

  @State selectedCategory: string = '全部'

  get categories(): string[] {
    const result: string[] = ['全部']
    this.articles.forEach((a: WikiArticle) => {
      if (result.indexOf(a.category) < 0) {
        result.push(a.category)
      }
    })
    return result
  }

  get filteredArticles(): WikiArticle[] {
    if (this.selectedCategory === '全部') return this.articles
    return this.articles.filter((a: WikiArticle) => a.category === this.selectedCategory)
  }

  build() {
    Column() {
      NavBar({ title: '非遗百科', showBack: true })

      Scroll() {
        Row() {
          ForEach(this.categories, (cat: string) => {
            Text(cat)
              .fontSize(12)
              .fontColor(this.selectedCategory === cat ? Color.White : Colors.TEXT_SECONDARY)
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .borderRadius(13)
              .backgroundColor(this.selectedCategory === cat ? Colors.PRIMARY : Colors.BG_CARD)
              .margin({ right: 8 })
              .onClick(() => { this.selectedCategory = cat })
          })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }
      .width('100%')
      .height(44)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .backgroundColor(Colors.BG_WHITE)

      Scroll() {
        Column() {
          ForEach(this.filteredArticles, (article: WikiArticle) => {
            Column() {
              Image(article.image)
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius({ topLeft: 8, topRight: 8 })

              Column() {
                Text(article.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Colors.TEXT_PRIMARY)
                  .width('100%')

                Text(article.summary)
                  .fontSize(13)
                  .fontColor(Colors.TEXT_SECONDARY)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .margin({ top: 8 })
                  .lineHeight(20)
              }
              .width('100%')
              .padding(14)
            }
            .width('100%')
            .borderRadius(8)
            .backgroundColor(Colors.BG_CARD)
            .margin({ left: 16, right: 16, top: 10 })
            .onClick(() => {
              const p: Record<string, Object> = {}
              p['id'] = article.id
              p['title'] = article.title
              router.pushUrl({ url: Constants.PAGE_WIKI_DETAIL, params: p })
            })
          })

          Row().height(16)
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
