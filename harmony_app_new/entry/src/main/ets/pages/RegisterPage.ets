import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import { LoginResult } from '../common/DataModels';

// 注册页：填写用户名、手机号、密码完成注册
@Entry
@Component
struct RegisterPage {
  @State username: string = '';   // 用户名
  @State phone: string = '';      // 手机号
  @State password: string = '';   // 密码
  @State loading: boolean = false; // 注册加载中

  // 执行注册请求，成功则保存token并跳转主页
  async doRegister() {
    if (!this.username || !this.phone || !this.password) {
      AlertDialog.show({ message: '请填写完整信息' });
      return;
    }
    this.loading = true;
    try {
      let res = await HttpUtil.post('/api/users/register', {
        username: this.username,
        phone: this.phone,
        password: this.password
      } as ESObject);
      let data = res.data as LoginResult;
      await HttpUtil.saveToken(data.token);
      router.replaceUrl({ url: 'pages/MainPage' });
    } catch (e) {
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      Text('注册')
        .fontSize(28).fontWeight(FontWeight.Bold).margin({ top: 60, bottom: 30 })

      TextInput({ placeholder: '用户名' }).width('80%').margin({ bottom: 14 })
        .onChange((v) => { this.username = v; })
      TextInput({ placeholder: '手机号' }).type(InputType.PhoneNumber).maxLength(11).width('80%').margin({ bottom: 14 })
        .onChange((v) => { this.phone = v; })
      TextInput({ placeholder: '密码' }).type(InputType.Password).width('80%').margin({ bottom: 28 })
        .onChange((v) => { this.password = v; })

      Button('注册').width('80%').enabled(!this.loading)
        .onClick(() => { this.doRegister(); })

      Button('返回登录').type(ButtonType.Normal).margin({ top: 12 })
        .onClick(() => { router.back(); })
    }
    .width('100%').height('100%')
  }
}
