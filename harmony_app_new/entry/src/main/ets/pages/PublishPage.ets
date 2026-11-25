import HttpUtil from '../common/HttpUtil';
import promptAction from '@ohos.promptAction';

// 发布页：提交非遗内容（标题/描述/媒体/标签/类型/关联商品）
@Component
export struct PublishComponent {
  @State title: string = '';         // 内容标题
  @State description: string = '';   // 内容描述
  @State tags: string = '';          // 标签（逗号分隔）
  @State type: string = 'image';     // 类型：image / video
  @State isSellable: boolean = false; // 是否关联商品售卖
  @State submitting: boolean = false; // 提交中标志
  @State mediaUrlStr: string = '';   // 媒体URL（逗号分隔）

  // 提交内容到后端审核
  async submit() {
    if (!this.title || !this.description) {
      promptAction.showToast({ message: '标题和描述不能为空' });
      return;
    }
    if (!this.mediaUrlStr) {
      promptAction.showToast({ message: '请提供至少一个媒体URL' });
      return;
    }
    this.submitting = true;
    try {
      let urls = this.mediaUrlStr.split(',').map(s => s.trim()).filter(s => s);
      let body: ESObject = {
        title: this.title,
        description: this.description,
        type: this.type,
        mediaUrls: JSON.stringify(urls),
        tags: this.tags,
        isSellable: this.isSellable
      };
      await HttpUtil.post('/api/contents', body);
      promptAction.showToast({ message: '提交成功，等待审核' });
      this.title = '';
      this.description = '';
      this.tags = '';
      this.mediaUrlStr = '';
      this.isSellable = false;
    } catch (e) {
    } finally {
      this.submitting = false;
    }
  }

  build() {
    Column() {
      Text('发布内容').fontSize(22).fontWeight(FontWeight.Bold).width('100%').padding(16)

      Scroll() {
        Column() {
          Text('媒体URL（逗号分隔多个）').fontSize(13).fontColor('#999').width('90%')
          TextInput({ placeholder: 'https://example.com/img1.jpg, https://...' })
            .width('90%').margin({ bottom: 14 })
            .onChange((v) => { this.mediaUrlStr = v; })

          Text('类型').fontSize(13).fontColor('#999').width('90%')
          Row() {
            Button('图片').type(this.type === 'image' ? ButtonType.Capsule : ButtonType.Normal)
              .onClick(() => { this.type = 'image'; })
            Button('视频').type(this.type === 'video' ? ButtonType.Capsule : ButtonType.Normal)
              .margin({ left: 12 })
              .onClick(() => { this.type = 'video'; })
          }.width('90%').margin({ bottom: 14 })

          Text('标题').fontSize(13).fontColor('#999').width('90%')
          TextInput({ placeholder: '请输入标题' }).width('90%').margin({ bottom: 14 })
            .onChange((v) => { this.title = v; })

          Text('描述').fontSize(13).fontColor('#999').width('90%')
          TextArea({ placeholder: '请输入描述' }).width('90%').height(100).margin({ bottom: 14 })
            .onChange((v) => { this.description = v; })

          Text('标签（逗号分隔）').fontSize(13).fontColor('#999').width('90%')
          TextInput({ placeholder: '非遗,手工艺,刺绣' }).width('90%').margin({ bottom: 14 })
            .onChange((v) => { this.tags = v; })

          Row() {
            Text('关联商品售卖').fontSize(14)
            Toggle({ type: ToggleType.Switch, isOn: false })
              .onChange((v) => { this.isSellable = v; })
          }.width('90%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 20 })

          Button('提交审核')
            .width('80%')
            .enabled(!this.submitting)
            .onClick(() => { this.submit(); })
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%')
  }
}
