// 登录页
import { router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { AuthService } from '../service/AuthService'

@Entry
@Component
struct Login {
  @State phone: string = ''
  @State code: string = ''
  @State codeSending: boolean = false
  @State logging: boolean = false

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor(Colors.TEXT_PRIMARY)
          .width(24)
          .height(24)
          .textAlign(TextAlign.Center)
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)

      Column() {
        Text('欢迎来到锤子铺')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)

        Text('发现并拥有中国手艺')
          .fontSize(14)
          .fontColor(Colors.TEXT_SECONDARY)
          .margin({ top: 8 })

        Row() {
          Text('+86')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Colors.TEXT_PRIMARY)
            .margin({ right: 12 })

          TextInput({ placeholder: '请输入手机号', text: this.phone })
            .fontSize(16)
            .layoutWeight(1)
            .height(44)
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => { this.phone = value })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .height(48)
        .borderRadius(8)
        .border({ width: 1, color: Colors.DIVIDER })
        .margin({ top: 32 })

        Row() {
          TextInput({ placeholder: '验证码', text: this.code })
            .fontSize(16)
            .layoutWeight(1)
            .height(44)
            .type(InputType.Number)
            .maxLength(6)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => { this.code = value })

          Text(this.codeSending ? '60s后重试' : '获取验证码')
            .fontSize(13)
            .fontColor(this.codeSending ? Colors.TEXT_HINT : Colors.PRIMARY)
            .onClick(() => {
              if (!this.codeSending && this.phone.length >= 11) {
                this.codeSending = true
                setTimeout(() => { this.codeSending = false }, 60000)
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .height(48)
        .borderRadius(8)
        .border({ width: 1, color: Colors.DIVIDER })
        .margin({ top: 16 })

        Button('登 录')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(24)
          .height(48)
          .width('100%')
          .margin({ top: 32 })
          .enabled(!this.logging)
          .onClick(async () => {
            if (this.phone.length >= 11 && this.code.length >= 4) {
              this.logging = true
              await AuthService.login(this.phone, this.code)
              this.logging = false
              router.back()
            }
          })

        Row() {
          Text('登录即表示同意')
            .fontSize(11)
            .fontColor(Colors.TEXT_HINT)
          Text('《用户协议》')
            .fontSize(11)
            .fontColor(Colors.PRIMARY)
          Text('和')
            .fontSize(11)
            .fontColor(Colors.TEXT_HINT)
          Text('《隐私政策》')
            .fontSize(11)
            .fontColor(Colors.PRIMARY)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 32, right: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PAPER)
  }
}
