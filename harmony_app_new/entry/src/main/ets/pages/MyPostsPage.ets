import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import { ContentItem } from '../common/DataModels';

// 我的发布页：展示当前用户发布的所有内容及其审核状态
@Entry
@Component
struct MyPostsPage {
  @State items: ContentItem[] = [];     // 我发布的内容列表
  @State loading: boolean = true;       // 初始加载中

  // 加载我的发布列表
  async aboutToAppear() {
    try {
      let res = await HttpUtil.get('/api/contents/mine');
      let arr = res.data as ContentItem[];
      for (let r of arr) {
        let item = new ContentItem();
        item.id = r.id;
        item.title = r.title;
        item.status = r.status;
        item.rejectReason = r.rejectReason;
        item.likeCount = r.likeCount;
        item.createdAt = r.createdAt;
        this.items.push(item);
      }
    } catch (e) {
    } finally {
      this.loading = false;
    }
  }

  // 将后端状态码转为中文展示文本
  statusText(s: string): string {
    let map: Record<string, string> = {
      'draft': '草稿', 'reviewing': '审核中', 'passed': '已通过', 'rejected': '已驳回'
    };
    return map[s] || s;
  }

  build() {
    Column() {
      Row() {
        Button('← 返回').type(ButtonType.Normal).onClick(() => { router.back(); })
        Text('我发布的').fontSize(18).fontWeight(FontWeight.Bold).margin({ left: 12 })
        Blank()
      }.width('100%').padding(12)

      if (this.loading) {
        LoadingProgress().width(28).height(28).margin({ top: 80 })
      } else if (this.items.length === 0) {
        Text('暂无发布').fontSize(16).fontColor('#999').margin({ top: 80 })
      } else {
        List() {
          ForEach(this.items, (item: ContentItem) => {
            ListItem() {
              Column() {
                Text(item.title).fontSize(15).width('100%')
                Row() {
                  Text(this.statusText(item.status)).fontSize(12)
                    .fontColor(item.status === 'passed' ? '#4CAF50' :
                               item.status === 'rejected' ? '#C62828' : '#FF9800')
                  Blank()
                  Text('❤ ' + item.likeCount).fontSize(12).fontColor('#999')
                }.width('100%').margin({ top: 4 })
                if (item.rejectReason) {
                  Text('驳回原因：' + item.rejectReason).fontSize(12).fontColor('#C62828').width('100%')
                }
              }
              .width('100%').padding(12)
              .border({ width: { bottom: 0.5 }, color: '#eee' })
            }
          })
        }.layoutWeight(1)
      }
    }
    .width('100%').height('100%')
  }
}
