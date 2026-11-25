import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import { ContentItem, ProductItem } from '../common/DataModels';

// 路由参数：接收contentId
interface DetailParams {
  contentId: number;
}

// 内容详情页：媒体展示、详情信息、关联商品、点赞
@Entry
@Component
struct ContentDetailPage {
  @State item: ContentItem = new ContentItem();      // 内容详情数据
  @State products: ProductItem[] = [];               // 关联商品列表
  @State loaded: boolean = false;                    // 是否加载完成
  private contentId: number = 0;                     // 当前内容ID

  // 页面出现时：获取路由参数并加载详情
  async aboutToAppear() {
    let params = router.getParams() as DetailParams;
    if (params) this.contentId = params.contentId;
    await this.loadDetail();
  }

  // 从后端加载内容详情及关联商品
  async loadDetail() {
    try {
      let res = await HttpUtil.get('/api/contents/' + this.contentId);
      let data = res.data as ContentItem;
      this.item.id = data.id;
      this.item.title = data.title;
      this.item.description = data.description;
      this.item.type = data.type;
      this.item.mediaUrls = data.mediaUrls;
      this.item.tags = data.tags;
      this.item.likeCount = data.likeCount;
      this.item.viewCount = data.viewCount;
      this.item.isSellable = data.isSellable;
      this.item.authorName = data.authorName;
      this.item.authorAvatar = data.authorAvatar;

      let prodList = data.products;
      if (prodList) {
        for (let p of prodList) {
          let prod = new ProductItem();
          prod.id = p.id;
          prod.name = p.name;
          prod.price = p.price;
          prod.stock = p.stock;
          prod.description = p.description;
          prod.images = p.images;
          this.products.push(prod);
        }
      }
      this.loaded = true;
    } catch (e) {
    }
  }

  // 点赞操作
  async doLike() {
    try {
      await HttpUtil.put('/api/contents/' + this.contentId + '/like', {} as ESObject);
      this.item.likeCount++;
    } catch (e) {}
  }

  // 解析mediaUrls JSON字符串为URL数组
  getMediaList(): string[] {
    try { return JSON.parse(this.item.mediaUrls) as string[]; }
    catch (e) { return []; }
  }

  // 跳转到订单详情页进行购买
  buyProduct(productId: number) {
    router.pushUrl({ url: 'pages/OrderDetailPage', params: { productId: productId } });
  }

  build() {
    Column() {
      if (!this.loaded) {
        LoadingProgress().width(36).height(36)
      }
      if (this.loaded) {
        Scroll() {
          Column() {
            Row() {
              Scroll() {
                Row() {
                  ForEach(this.getMediaList(), (url: string, index: number) => {
                    Image(url)
                      .width(360).height(240)
                      .objectFit(ImageFit.Cover)
                      .margin({ right: 4 })
                  })
                }
              }
              .scrollable(ScrollDirection.Horizontal)
            }
            .width('100%')

            Column() {
              Text(this.item.title).fontSize(20).fontWeight(FontWeight.Bold).width('100%')
              Row() {
                Text(this.item.authorName).fontSize(13).fontColor('#999')
                Blank()
                Text('❤ ' + this.item.likeCount).fontSize(13).fontColor('#C62828')
                Text('  👁 ' + this.item.viewCount).fontSize(13).fontColor('#999')
              }.width('100%').margin({ top: 8 })

              Text(this.item.description).fontSize(15).fontColor('#333')
                .width('100%').margin({ top: 16 }).lineHeight(24)

              if (this.item.tags) {
                Row() {
                  ForEach(this.item.tags.split(','), (tag: string) => {
                    Text(tag.trim())
                      .fontSize(11).fontColor('#C62828')
                      .backgroundColor('#FFF0F0')
                      .borderRadius(10).padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .margin({ right: 6 })
                  })
                }.width('100%').margin({ top: 12 })
              }

              if (this.products.length > 0) {
                Text('关联商品').fontSize(17).fontWeight(FontWeight.Bold).margin({ top: 24, bottom: 10 })
                ForEach(this.products, (prod: ProductItem) => {
                  Row() {
                    Column() {
                      Text(prod.name).fontSize(14).fontWeight(FontWeight.Medium)
                      Text(prod.description).fontSize(12).fontColor('#999').maxLines(2)
                    }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                    Column() {
                      Text('¥' + prod.price).fontSize(16).fontColor('#C62828').fontWeight(FontWeight.Bold)
                      Button('购买').fontSize(12).margin({ top: 4 })
                        .onClick(() => { this.buyProduct(prod.id); })
                    }
                  }
                  .width('100%').padding(12)
                  .border({ width: 1, color: '#eee', radius: 8 })
                  .margin({ bottom: 8 })
                })
              }
            }
            .width('100%').padding(16)
          }
          .width('100%')
        }
        .layoutWeight(1)

        Row() {
          Button('❤ 点赞').type(ButtonType.Normal).onClick(() => { this.doLike(); })
          Blank()
          Button('返回').type(ButtonType.Normal).onClick(() => { router.back(); })
        }
        .width('100%').padding(12)
      }
    }
    .width('100%').height('100%')
    .justifyContent(this.loaded ? FlexAlign.Start : FlexAlign.Center)
  }
}
