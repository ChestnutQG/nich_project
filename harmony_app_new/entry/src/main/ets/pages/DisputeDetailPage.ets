import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import { DisputeItem } from '../common/DataModels';
import promptAction from '@ohos.promptAction';

// 路由参数：可选的disputeId，有则显示单个纠纷
interface DisputeDetailParams {
  disputeId?: number;
}

// 纠纷详情页：展示单条纠纷或全部我的纠纷列表，支持申请陪审
@Entry
@Component
struct DisputeDetailPage {
  @State disputes: DisputeItem[] = [];       // 纠纷列表
  @State loading: boolean = true;            // 加载中
  private disputeId: number = 0;             // 指定纠纷ID（单条模式）
  private showSingle: boolean = false;       // 是否为单条模式

  // 根据参数决定加载单条还是全部纠纷
  async aboutToAppear() {
    let params = router.getParams() as DisputeDetailParams;
    if (params && params.disputeId) {
      this.disputeId = params.disputeId;
      this.showSingle = true;
      await this.loadOne();
    } else {
      await this.loadMine();
    }
  }

  // 加载单条纠纷详情
  async loadOne() {
    try {
      let res = await HttpUtil.get('/api/disputes/' + this.disputeId);
      let data = res.data as DisputeItem;
      let d = new DisputeItem();
      d.id = data.id;
      d.orderId = data.orderId;
      d.reason = data.reason;
      d.status = data.status;
      d.result = data.result;
      d.buyerSupportRate = data.buyerSupportRate;
      this.disputes.push(d);
    } catch (e) {
    } finally {
      this.loading = false;
    }
  }

  // 加载当前用户的所有纠纷
  async loadMine() {
    try {
      let res = await HttpUtil.get('/api/disputes/mine');
      let arr = res.data as DisputeItem[];
      for (let r of arr) {
        let d = new DisputeItem();
        d.id = r.id;
        d.orderId = r.orderId;
        d.reason = r.reason;
        d.status = r.status;
        d.result = r.result;
        d.buyerSupportRate = r.buyerSupportRate;
        this.disputes.push(d);
      }
    } catch (e) {
    } finally {
      this.loading = false;
    }
  }

  // 请求陪审团介入指定纠纷
  async requestJury(did: number) {
    try {
      await HttpUtil.put('/api/disputes/' + did + '/request-jury', {} as ESObject);
      promptAction.showToast({ message: '已申请陪审团介入' });
    } catch (e) {}
  }

  // 将纠纷状态码转为中文展示文本
  statusText(s: string): string {
    let map: Record<string, string> = {
      'negotiating': '协商中', 'pending_jury': '待陪审', 'voting': '投票中', 'resolved': '已裁决'
    };
    return map[s] || s;
  }

  build() {
    Column() {
      Row() {
        Button('←').type(ButtonType.Normal).onClick(() => { router.back(); })
        Text(this.showSingle ? '纠纷详情' : '我的纠纷').fontSize(18).fontWeight(FontWeight.Bold).margin({ left: 12 })
        Blank()
      }.width('100%').padding(12)

      if (this.loading) {
        LoadingProgress().width(28).height(28).margin({ top: 80 })
      } else if (this.disputes.length === 0) {
        Text('暂无纠纷').fontSize(16).fontColor('#999').margin({ top: 80 })
      } else {
        List() {
          ForEach(this.disputes, (d: DisputeItem) => {
            ListItem() {
              Column() {
                Text('纠纷 #' + d.id + ' (订单 #' + d.orderId + ')').fontSize(15).fontWeight(FontWeight.Medium)
                Text('原因：' + d.reason).fontSize(13).fontColor('#666').maxLines(2).margin({ top: 4 })
                Row() {
                  Text(this.statusText(d.status)).fontSize(12).fontColor('#FF9800')
                  if (d.result) {
                    Text(' | 结果：' + (d.result === 'buyer_win' ? '买家胜诉' : '卖家胜诉'))
                      .fontSize(12).fontColor(d.result === 'buyer_win' ? '#4CAF50' : '#C62828')
                  }
                  if (d.buyerSupportRate) {
                    Text(' | 支持率：' + d.buyerSupportRate + '%').fontSize(12)
                  }
                }.width('100%').margin({ top: 6 })

                if (d.status === 'negotiating') {
                  Button('申请陪审').fontSize(12).margin({ top: 8 })
                    .onClick(() => { this.requestJury(d.id); })
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
