import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import { OrderItem } from '../common/DataModels';

// 路由参数：bought=我买到的 / sold=我卖出的
interface OrderListParams {
  type: string;
}

// 订单列表页：根据路由参数展示买到的或卖出的订单
@Entry
@Component
struct OrderListPage {
  @State orders: OrderItem[] = [];      // 订单列表
  @State loading: boolean = true;       // 加载中标志
  @State title: string = '订单';         // 页面标题
  private listType: string = 'bought';  // 列表类型：bought / sold

  // 根据路由参数加载对应订单列表
  async aboutToAppear() {
    let params = router.getParams() as OrderListParams;
    if (params) this.listType = params.type;
    this.title = this.listType === 'bought' ? '我买到的' : '我卖出的';

    try {
      let path = this.listType === 'bought' ? '/api/orders/bought' : '/api/orders/sold';
      let res = await HttpUtil.get(path);
      let arr = res.data as OrderItem[];
      for (let r of arr) {
        let o = new OrderItem();
        o.id = r.id;
        o.productId = r.productId;
        o.amount = r.amount;
        o.status = r.status;
        o.afterSaleStatus = r.afterSaleStatus;
        o.createdAt = r.createdAt;
        this.orders.push(o);
      }
    } catch (e) {
    } finally {
      this.loading = false;
    }
  }

  // 将订单状态码转为中文展示文本
  statusText(s: string): string {
    let map: Record<string, string> = {
      'pending': '待付款', 'paid': '已付款', 'shipped': '已发货',
      'received': '已收货', 'completed': '已完成'
    };
    return map[s] || s;
  }

  build() {
    Column() {
      Row() {
        Button('← 返回').type(ButtonType.Normal).onClick(() => { router.back(); })
        Text(this.title).fontSize(18).fontWeight(FontWeight.Bold).margin({ left: 12 })
        Blank()
      }.width('100%').padding(12)

      if (this.loading) {
        LoadingProgress().width(28).height(28).margin({ top: 80 })
      } else if (this.orders.length === 0) {
        Text('暂无订单').fontSize(16).fontColor('#999').margin({ top: 80 })
      } else {
        List() {
          ForEach(this.orders, (o: OrderItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text('订单 #' + o.id).fontSize(14).fontWeight(FontWeight.Medium)
                  Blank()
                  Text('¥' + o.amount).fontSize(16).fontColor('#C62828').fontWeight(FontWeight.Bold)
                }.width('100%')
                Row() {
                  Text(this.statusText(o.status)).fontSize(12).fontColor('#FF9800')
                  if (o.afterSaleStatus !== 'none') {
                    Text(' | 售后：' + o.afterSaleStatus).fontSize(12).fontColor('#C62828')
                  }
                  Blank()
                  Text(o.createdAt).fontSize(11).fontColor('#999')
                }.width('100%').margin({ top: 4 })
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
