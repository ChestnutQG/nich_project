// 登录页 — 手机号+密码登录 · 国风版
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { AuthService } from '../service/AuthService'
import { LoginResult } from '../model/User'
import { ApiResponse } from '../model/ApiResponse'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct Login {
  @State phone: string = ''
  @State password: string = ''
  @State logging: boolean = false
  @State isRegister: boolean = false
  @State username: string = ''
  @State remember: boolean = true

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(this.fs(22))
          .fontColor(Theme.textPrimary(this.theme))
          .width(24)
          .height(24)
          .textAlign(TextAlign.Center)
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)

      Scroll() {
        Column() {
          Text(this.isRegister ? this.t('注册账号', 'Register') : this.t('欢迎来到锤子铺', 'Welcome to Chuizhi'))
            .fontSize(this.fs(28))
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textPrimary(this.theme))
            .letterSpacing(2)

          Text(this.isRegister ? this.t('加入非遗守护者', 'Join as a heritage guardian') : this.t('发现并拥有中国手艺', 'Discover Chinese craftsmanship'))
            .fontSize(this.fs(14))
            .fontColor(Theme.textSecondary(this.theme))
            .margin({ top: 10 })

          // 装饰分隔线
          Row() {
            Column().width(40).height(1).backgroundColor(Theme.divider(this.theme))
            Text(' · ')
              .fontSize(16)
              .fontColor(Theme.textHint(this.theme))
            Column().width(40).height(1).backgroundColor(Theme.divider(this.theme))
          }
          .margin({ top: 24 })
          .justifyContent(FlexAlign.Center)
          .width('100%')

          // 注册时显示用户名输入
          if (this.isRegister) {
            Row() {
              TextInput({ placeholder: this.t('请输入用户名', 'Username'), text: this.username })
                .fontSize(this.fs(16))
                .layoutWeight(1)
                .height(44)
                .backgroundColor(Color.Transparent)
                .fontColor(Theme.textPrimary(this.theme))
                .placeholderColor(Theme.textHint(this.theme))
                .onChange((value: string) => { this.username = value })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .height(48)
            .borderRadius(4)
            .border({ width: 1, color: Theme.divider(this.theme) })
            .margin({ top: 24 })
          }

          Row() {
            Text('+86')
              .fontSize(this.fs(16))
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.textPrimary(this.theme))
              .margin({ right: 12 })

            TextInput({ placeholder: this.t('请输入手机号', 'Phone number'), text: this.phone })
              .fontSize(this.fs(16))
              .layoutWeight(1)
              .height(44)
              .type(InputType.PhoneNumber)
              .maxLength(11)
              .backgroundColor(Color.Transparent)
              .fontColor(Theme.textPrimary(this.theme))
              .placeholderColor(Theme.textHint(this.theme))
              .onChange((value: string) => { this.phone = value })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .height(48)
          .borderRadius(4)
          .border({ width: 1, color: Theme.divider(this.theme) })
          .margin({ top: 24 })

          Row() {
            TextInput({ placeholder: this.t('请输入密码', 'Password'), text: this.password })
              .fontSize(this.fs(16))
              .layoutWeight(1)
              .height(44)
              .type(InputType.Password)
              .backgroundColor(Color.Transparent)
              .fontColor(Theme.textPrimary(this.theme))
              .placeholderColor(Theme.textHint(this.theme))
              .onChange((value: string) => { this.password = value })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .height(48)
          .borderRadius(4)
          .border({ width: 1, color: Theme.divider(this.theme) })
          .margin({ top: 16 })

          // 记住登录
          Row() {
            Checkbox()
              .select(this.remember)
              .selectedColor(Theme.primary(this.theme))
              .width(20)
              .height(20)
              .onChange((value: boolean) => { this.remember = value })
            Text(this.t('记住登录', 'Remember me'))
              .fontSize(this.fs(13))
              .fontColor(Theme.textSecondary(this.theme))
              .margin({ left: 6 })
              .onClick(() => { this.remember = !this.remember })
            Blank()
          }
          .width('100%')
          .margin({ top: 16 })

          Button(this.isRegister ? this.t('注 册', 'Register') : this.t('登 录', 'Sign In'))
            .fontSize(this.fs(16))
            .fontWeight(FontWeight.Medium)
            .backgroundColor(Theme.primary(this.theme))
            .borderRadius(4)
            .height(48)
            .width('100%')
            .margin({ top: 32 })
            .enabled(!this.logging)
            .onClick(async () => {
              if (this.phone.length < 11) {
                promptAction.showToast({ message: this.t('请输入正确的手机号', 'Please enter a valid phone number') })
                return
              }
              if (this.password.length < 6) {
                promptAction.showToast({ message: this.t('密码至少6位', 'Password must be at least 6 characters') })
                return
              }
              if (this.isRegister && !this.username) {
                promptAction.showToast({ message: this.t('请输入用户名', 'Please enter a username') })
                return
              }

              this.logging = true
              let resp: ApiResponse<LoginResult>
              if (this.isRegister) {
                resp = await AuthService.register(this.username, this.phone, this.password, this.remember)
              } else {
                resp = await AuthService.login(this.phone, this.password, this.remember)
              }
              this.logging = false

              if (resp.code === 0) {
                promptAction.showToast({ message: this.isRegister ? this.t('注册成功', 'Registered') : this.t('登录成功', 'Signed in') })
                router.back()
              } else {
                promptAction.showToast({ message: resp.message || this.t('操作失败', 'Failed') })
              }
            })

          Row() {
            Text(this.isRegister ? this.t('已有账号？', 'Have an account? ') : this.t('没有账号？', 'No account? '))
              .fontSize(this.fs(13))
              .fontColor(Theme.textSecondary(this.theme))
            Text(this.isRegister ? this.t('去登录', 'Sign in') : this.t('去注册', 'Register'))
              .fontSize(this.fs(13))
              .fontColor(Theme.primary(this.theme))
              .onClick(() => {
                this.isRegister = !this.isRegister
                this.username = ''
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 24 })
        }
        .width('100%')
        .padding({ left: 32, right: 32 })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg(this.theme))
  }
}
