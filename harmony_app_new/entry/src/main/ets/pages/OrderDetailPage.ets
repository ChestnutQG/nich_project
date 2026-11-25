import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import promptAction from '@ohos.promptAction';
import { OrderItem } from '../common/DataModels';

// 路由参数：productId=新建订单 / orderId=查看已有订单
interface OrderDetailParams {
  productId?: number;
  orderId?: number;
}

// 订单详情页：创建订单 / 查看详情 / 操作（付款/发货/收货/售后）
@Entry
@Component
struct OrderDetailPage {
  @State order: OrderItem = new OrderItem();        // 订单数据
  @State loaded: boolean = false;                   // 是否加载完成
  @State actionLoading: boolean = false;            // 操作执行中
  private productId: number = 0;                    // 用于创建订单的商品ID
  private orderId: number = 0;                      // 已有订单ID

  // 页面出现时：有productId则建单，有orderId则加载订单
  async aboutToAppear() {
    let params = router.getParams() as OrderDetailParams;
    if (params) {
      this.productId = params.productId || 0;
      this.orderId = params.orderId || 0;
    }
    if (this.productId > 0) {
      await this.createOrder();
    } else if (this.orderId > 0) {
      await this.loadOrder();
    }
  }

  // 创建新订单
  async createOrder() {
    this.actionLoading = true;
    try {
      let body: ESObject = { productId: this.productId };
      let res = await HttpUtil.post('/api/orders', body);
      let data = res.data as OrderItem;
      this.order.id = data.id;
      this.order.productId = data.productId;
      this.order.amount = data.amount;
      this.order.status = data.status;
      this.loaded = true;
      promptAction.showToast({ message: '下单成功' });
    } catch (e) {
    } finally {
      this.actionLoading = false;
    }
  }

  // 加载已有订单详情
  async loadOrder() {
    try {
      let res = await HttpUtil.get('/api/orders/' + this.orderId);
      let data = res.data as OrderItem;
      this.order.id = data.id;
      this.order.productId = data.productId;
      this.order.buyerId = data.buyerId;
      this.order.sellerId = data.sellerId;
      this.order.amount = data.amount;
      this.order.status = data.status;
      this.order.afterSaleStatus = data.afterSaleStatus;
      this.order.logisticsNo = data.logisticsNo;
      this.loaded = true;
    } catch (e) {
    }
  }

  // 执行订单操作：pay/ship/confirm
  async doAction(action: string) {
    this.actionLoading = true;
    try {
      await HttpUtil.put('/api/orders/' + this.order.id + '/' + action, {} as ESObject);
      promptAction.showToast({ message: '操作成功' });
      await this.loadOrder();
    } catch (e) {
    } finally {
      this.actionLoading = false;
    }
  }

  build() {
    Column() {
      Row() {
        Button('←').type(ButtonType.Normal).onClick(() => { router.back(); })
        Text('订单详情').fontSize(18).fontWeight(FontWeight.Bold).margin({ left: 12 })
        Blank()
      }.width('100%').padding(12)

      if (!this.loaded) {
        LoadingProgress().width(28).height(28).margin({ top: 80 })
      } else {
        Scroll() {
          Column() {
            Text('订单 #' + this.order.id).fontSize(22).fontWeight(FontWeight.Bold)
            Text('¥' + this.order.amount).fontSize(32).fontColor('#C62828').fontWeight(FontWeight.Bold).margin({ top: 8 })
            Text('状态：' + this.order.status).fontSize(15).margin({ top: 12 })

            if (this.order.logisticsNo) {
              Text('物流单号：' + this.order.logisticsNo).fontSize(13).fontColor('#999').margin({ top: 8 })
            }

            Divider().margin({ top: 20, bottom: 20 })

            if (this.order.status === 'pending') {
              Button('去付款').width('80%')
                .enabled(!this.actionLoading)
                .onClick(() => { this.doAction('pay'); })
            } else if (this.order.status === 'paid') {
              Button('去发货').width('80%')
                .enabled(!this.actionLoading)
                .onClick(() => { this.doAction('ship'); })
            } else if (this.order.status === 'shipped') {
              Button('确认收货').width('80%')
                .enabled(!this.actionLoading)
                .onClick(() => { this.doAction('confirm'); })
            } else if (this.order.status === 'received' && this.order.afterSaleStatus === 'none') {
              Button('申请售后/小法庭').width('80%')
                .onClick(() => {
                  router.pushUrl({ url: 'pages/DisputeApplyPage', params: { orderId: this.order.id } });
                })
            }
          }
          .width('100%').padding(16)
        }.layoutWeight(1)
      }
    }
    .width('100%').height('100%')
  }
}
