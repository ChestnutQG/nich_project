// 登录页 — 手机号+密码登录
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Constants } from '../common/Constants'
import { AuthService } from '../service/AuthService'
import { LoginResult } from '../model/User'
import { ApiResponse } from '../model/ApiResponse'

interface TestAccount {
  label: string
  phone: string
  password: string
}

@Entry
@Component
struct Login {
  @State phone: string = '13800000001'
  @State password: string = '123456'
  @State logging: boolean = false
  @State isRegister: boolean = false
  @State username: string = ''

  private testAccounts: TestAccount[] = [
    { label: '管理员', phone: '13800000001', password: '123456' },
    { label: '传承人', phone: '13800000002', password: '123456' },
    { label: '用户', phone: '13800000003', password: '123456' }
  ]

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

      Scroll() {
        Column() {
          Text(this.isRegister ? '注册账号' : '欢迎来到锤子铺')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.TEXT_PRIMARY)

          Text(this.isRegister ? '加入非遗守护者' : '发现并拥有中国手艺')
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
            .margin({ top: 8 })

          // 测试账号快速切换
          if (!this.isRegister) {
            Row() {
              ForEach(this.testAccounts, (acc: TestAccount) => {
                Text(acc.label)
                  .fontSize(11)
                  .fontColor(this.phone === acc.phone ? Colors.BG_WHITE : Colors.TEXT_SECONDARY)
                  .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                  .borderRadius(14)
                  .backgroundColor(this.phone === acc.phone ? Colors.PRIMARY : Colors.BG_PAPER)
                  .margin({ right: 10 })
                  .onClick(() => {
                    this.phone = acc.phone
                    this.password = acc.password
                  })
              })
            }
            .width('100%')
            .margin({ top: 20 })
          }

          // 注册时显示用户名输入
          if (this.isRegister) {
            Row() {
              TextInput({ placeholder: '请输入用户名', text: this.username })
                .fontSize(16)
                .layoutWeight(1)
                .height(44)
                .backgroundColor(Color.Transparent)
                .onChange((value: string) => { this.username = value })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .height(48)
            .borderRadius(8)
            .border({ width: 1, color: Colors.DIVIDER })
            .margin({ top: 24 })
          }

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
          .margin({ top: 24 })

          Row() {
            TextInput({ placeholder: '请输入密码', text: this.password })
              .fontSize(16)
              .layoutWeight(1)
              .height(44)
              .type(InputType.Password)
              .backgroundColor(Color.Transparent)
              .onChange((value: string) => { this.password = value })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .height(48)
          .borderRadius(8)
          .border({ width: 1, color: Colors.DIVIDER })
          .margin({ top: 16 })

          Button(this.isRegister ? '注 册' : '登 录')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(Colors.PRIMARY)
            .borderRadius(24)
            .height(48)
            .width('100%')
            .margin({ top: 32 })
            .enabled(!this.logging)
            .onClick(async () => {
              if (this.phone.length < 11) {
                promptAction.showToast({ message: '请输入正确的手机号' })
                return
              }
              if (this.password.length < 6) {
                promptAction.showToast({ message: '密码至少6位' })
                return
              }
              if (this.isRegister && !this.username) {
                promptAction.showToast({ message: '请输入用户名' })
                return
              }

              this.logging = true
              let resp: ApiResponse<LoginResult>
              if (this.isRegister) {
                resp = await AuthService.register(this.username, this.phone, this.password)
              } else {
                resp = await AuthService.login(this.phone, this.password)
              }
              this.logging = false

              if (resp.code === 0) {
                promptAction.showToast({ message: this.isRegister ? '注册成功' : '登录成功' })
                router.back()
              } else {
                promptAction.showToast({ message: resp.message || '操作失败' })
              }
            })

          Row() {
            Text(this.isRegister ? '已有账号？' : '没有账号？')
              .fontSize(13)
              .fontColor(Colors.TEXT_SECONDARY)
            Text(this.isRegister ? '去登录' : '去注册')
              .fontSize(13)
              .fontColor(Colors.PRIMARY)
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
    .backgroundColor(Colors.BG_PAPER)
  }
}
