import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import { ContentItem, PageResult } from '../common/DataModels';
import promptAction from '@ohos.promptAction';

// 发现页：内容信息流，支持上拉加载、下拉刷新、排序切换
@Component
export struct FeedComponent {
  @State items: ContentItem[] = [];      // 内容列表数据
  @State loading: boolean = false;       // 加载中标志
  @State page: number = 1;               // 当前页码
  @State hasMore: boolean = true;        // 是否还有更多数据
  @State sortBy: string = 'newest';      // 排序方式：newest/hotest
  @State tag: string = '';               // 标签筛选
  @State refreshing: boolean = false;    // 下拉刷新状态

  aboutToAppear() {
    this.loadData();
  }

  // 加载内容列表（支持刷新/追加两种模式）
  async loadData(isRefresh?: boolean) {
    if (this.loading) return;
    if (isRefresh) { this.page = 1; this.hasMore = true; }
    this.loading = true;

    try {
      let params = '?page=' + this.page + '&size=10&sort=' + this.sortBy;
      if (this.tag) params += '&tag=' + this.tag;

      let res = await HttpUtil.get('/api/contents' + params);
      let pageData = res.data as PageResult<ContentItem>;
      let records = pageData.records;
      let mapped: ContentItem[] = [];

      for (let i = 0; i < records.length; i++) {
        let r = records[i];
        let item = new ContentItem();
        item.id = r.id;
        item.title = r.title;
        item.description = r.description;
        item.type = r.type;
        item.mediaUrls = r.mediaUrls;
        item.tags = r.tags;
        item.likeCount = r.likeCount;
        item.viewCount = r.viewCount;
        item.isSellable = r.isSellable;
        item.authorName = r.authorName;
        item.authorAvatar = r.authorAvatar;
        item.createdAt = r.createdAt;
        mapped.push(item);
      }

      if (isRefresh) {
        this.items = mapped;
      } else {
        this.items = this.items.concat(mapped);
      }
      this.hasMore = pageData.total > this.items.length;
      this.page++;
    } catch (e) {
      promptAction.showToast({ message: '加载失败', duration: 2000 });
    } finally {
      this.loading = false;
      this.refreshing = false;
    }
  }

  // 从JSON格式的mediaUrls中提取第一张缩略图
  getThumb(urls: string): string {
    try {
      let arr = JSON.parse(urls) as string[];
      return (arr && arr.length > 0) ? arr[0] : '';
    } catch (e) {
      return '';
    }
  }

  build() {
    Column() {
      Row() {
        Text('国风非遗').fontSize(22).fontWeight(FontWeight.Bold)
        Blank()
        Button(this.sortBy === 'newest' ? '最新' : '最热')
          .type(ButtonType.Normal)
          .onClick(() => {
            this.sortBy = this.sortBy === 'newest' ? 'hotest' : 'newest';
            this.page = 1;
            this.loadData(true);
          })
      }
      .width('100%').padding(16)

      if (this.items.length === 0 && !this.loading) {
        Column() {
          Text('暂无内容').fontSize(16).fontColor('#999').margin({ top: 100 })
        }.width('100%').layoutWeight(1)
      } else {
        Refresh({ refreshing: $$this.refreshing }) {
          List() {
            ForEach(this.items, (item: ContentItem, index: number) => {
              ListItem() {
                this.CardBuilder(item)
              }
            })
          }
          .width('100%').height('100%')
          .onReachEnd(() => {
            if (this.hasMore && !this.loading) this.loadData(false);
          })
        }
        .onRefreshing(() => {
          this.refreshing = true;
          this.loadData(true);
        })
        .layoutWeight(1)
      }

      if (this.loading) {
        LoadingProgress().width(28).height(28).margin({ bottom: 12 })
      }
    }
    .width('100%').height('100%')
  }

  // 内容卡片构建器：缩略图+标题+作者信息，点击进入详情
  @Builder CardBuilder(item: ContentItem) {
    Column() {
      Image(this.getThumb(item.mediaUrls))
        .width('100%').height(180).objectFit(ImageFit.Cover)
        .borderRadius(8)

      Text(item.title)
        .fontSize(15).fontWeight(FontWeight.Medium)
        .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%').margin({ top: 8 })

      Row() {
        Text(item.authorName).fontSize(12).fontColor('#999')
        Blank()
        Text('❤ ' + item.likeCount).fontSize(12).fontColor('#C62828')
        Text('  👁 ' + item.viewCount).fontSize(12).fontColor('#999').margin({ left: 8 })
      }
      .width('100%').margin({ top: 4 })
    }
    .width('100%').padding(12)
    .onClick(() => {
      router.pushUrl({ url: 'pages/ContentDetailPage', params: { contentId: item.id } });
    })
  }
}
