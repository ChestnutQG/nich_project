import router from '@ohos.router';
import HttpUtil from '../common/HttpUtil';
import { LoginResult } from '../common/DataModels';

// 登录页：手机号+密码登录，已登录自动跳转主页
@Entry
@Component
struct LoginPage {
  @State phone: string = '';       // 手机号输入
  @State password: string = '';    // 密码输入
  @State loading: boolean = false;  // 登录加载中标志

  // 页面出现时：初始化HttpUtil，若已有token则跳过登录
  async aboutToAppear() {
    await HttpUtil.init();
    let token = await HttpUtil.getToken();
    if (token) {
      router.replaceUrl({ url: 'pages/MainPage' });
    }
  }

  // 执行登录请求
  async doLogin() {
    if (!this.phone || !this.password) {
      AlertDialog.show({ message: '请输入手机号和密码' });
      return;
    }
    this.loading = true;
    try {
      let res = await HttpUtil.post('/api/users/login', {
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
      Text('国风非遗')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 80, bottom: 40 })

      TextInput({ placeholder: '手机号' })
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .width('80%')
        .margin({ bottom: 16 })
        .onChange((v) => { this.phone = v; })

      TextInput({ placeholder: '密码' })
        .type(InputType.Password)
        .width('80%')
        .margin({ bottom: 32 })
        .onChange((v) => { this.password = v; })

      Button('登录')
        .width('80%')
        .enabled(!this.loading)
        .onClick(() => { this.doLogin(); })

      Button('注册新账号')
        .type(ButtonType.Normal)
        .margin({ top: 16 })
        .onClick(() => { router.pushUrl({ url: 'pages/RegisterPage' }); })
    }
    .width('100%')
    .height('100%')
  }
}
