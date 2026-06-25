import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import promptAction from '@ohos.promptAction';

// 路由参数：关联的订单ID
interface DisputeApplyParams {
  orderId: number;
}

// 发起纠纷/小法庭页：填写纠纷原因及证据
@Entry
@Component
struct DisputeApplyPage {
  @State reason: string = '';         // 纠纷原因
  @State evidenceUrls: string = '';   // 证据链接（逗号分隔）
  @State submitting: boolean = false; // 提交中标志
  private orderId: number = 0;        // 关联订单ID

  // 获取路由参数中的订单ID
  aboutToAppear() {
    let params = router.getParams() as DisputeApplyParams;
    if (params) this.orderId = params.orderId;
  }

  // 提交纠纷申请到后端
  async submit() {
    if (!this.reason) {
      promptAction.showToast({ message: '请填写纠纷原因' });
      return;
    }
    this.submitting = true;
    try {
      let body: ESObject = {
        orderId: this.orderId,
        reason: this.reason,
        evidenceUrls: this.evidenceUrls || '[]'
      };
      await HttpUtil.post('/api/disputes', body);
      promptAction.showToast({ message: '纠纷已发起' });
      router.back();
    } catch (e) {
    } finally {
      this.submitting = false;
    }
  }

  build() {
    Column() {
      Row() {
        Button('←').type(ButtonType.Normal).onClick(() => { router.back(); })
        Text('发起纠纷').fontSize(18).fontWeight(FontWeight.Bold).margin({ left: 12 })
        Blank()
      }.width('100%').padding(12)

      Column() {
        Text('订单 #' + this.orderId).fontSize(16).margin({ bottom: 16 })

        Text('纠纷原因').fontSize(14).fontColor('#999').width('85%')
        TextArea({ placeholder: '请详细描述问题...' }).width('85%').height(120).margin({ bottom: 14 })
          .onChange((v) => { this.reason = v; })

        Text('证据URL（可选，逗号分隔）').fontSize(14).fontColor('#999').width('85%')
        TextInput({ placeholder: 'https://...' }).width('85%').margin({ bottom: 24 })
          .onChange((v) => { this.evidenceUrls = v; })

        Button('提交纠纷').width('80%').enabled(!this.submitting)
          .onClick(() => { this.submit(); })
      }
      .width('100%').layoutWeight(1).padding(16)
    }
    .width('100%').height('100%')
  }
}
