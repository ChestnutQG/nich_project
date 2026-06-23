// 编辑资料页面 — 修改头像/昵称/手机号（手机号需验证码验证后修改）
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { Colors } from '../common/Colors'
import { NavBar } from '../components/NavBar'
import { ApiClient } from '../service/ApiClient'
import { User } from '../model/User'

@Entry
@Component
struct ProfileEdit {
  @State nickname: string = ''
  @State avatar: string = ''
  @State phone: string = ''
  @State saving: boolean = false
  @State uploading: boolean = false
  @State loading: boolean = true

  // 暂存的本地新头像 URI（选完还没上传）
  private pendingAvatarUri: string = ''

  // 手机号验证码流程：先输新号 → 对【新号】发验证码 → 验证通过才生效
  @State showVerifyModal: boolean = false
  @State showNewPhoneModal: boolean = false
  @State verifyCode: string = ''        // 生成的6位验证码
  @State inputCode: string = ''         // 用户输入的验证码
  @State newPhone: string = ''          // 新手机号
  private phoneChanged: boolean = false

  aboutToAppear(): void {
    this.loadUser()
  }

  async loadUser(): Promise<void> {
    const resp = await ApiClient.get<User>('/users/1')
    if (resp.code === 0 && resp.data) {
      this.nickname = resp.data.nickname || ''
      this.avatar = resp.data.avatar || ''
      this.phone = resp.data.phone || ''
    }
    this.loading = false
  }

  build() {
    Stack() {
      Column() {
        NavBar({ title: '编辑资料', showBack: true })

        if (this.loading) {
          Row() {
            LoadingProgress().width(24).height(24).color(Colors.PRIMARY)
            Text('加载中...').fontSize(14).fontColor(Colors.TEXT_HINT).margin({ left: 8 })
          }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              // 头像
              Column() {
                Text('头像').fontSize(13).fontColor(Colors.TEXT_SECONDARY).width('100%')
                  .padding({ left: 16, right: 16, top: 20, bottom: 8 })

                Row() {
                  if (this.pendingAvatarUri) {
                    Image(this.pendingAvatarUri)
                      .width(72).height(72).borderRadius(36).objectFit(ImageFit.Cover)
                  } else if (this.avatar) {
                    Image(this.avatar)
                      .width(72).height(72).borderRadius(36).objectFit(ImageFit.Cover)
                  } else {
                    Text(this.nickname ? this.nickname.charAt(0) : '?')
                      .fontSize(30)
                      .fontColor(Colors.BG_WHITE)
                      .width(72)
                      .height(72)
                      .borderRadius(36)
                      .backgroundColor(Colors.PRIMARY_LIGHT)
                      .textAlign(TextAlign.Center)
                      .lineHeight(72)
                  }

                  Text('点击更换头像')
                    .fontSize(13).fontColor(Colors.TEXT_HINT).margin({ left: 16 })
                }
                .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .backgroundColor(Colors.BG_WHITE)
                .borderRadius(8)
                .margin({ left: 16, right: 16 })
                .onClick(() => { this.pickAvatar() })
              }

              // 基本信息
              Text('基本信息')
                .fontSize(13).fontColor(Colors.TEXT_SECONDARY).width('100%')
                .padding({ left: 16, right: 16, top: 24, bottom: 8 })

              Column() {
                // 昵称 — 直接编辑
                Row() {
                  Text('昵称').fontSize(15).fontColor(Colors.TEXT_PRIMARY).width(80)
                  TextInput({ placeholder: '请输入昵称', text: this.nickname })
                    .fontSize(15).fontColor(Colors.TEXT_PRIMARY).placeholderColor(Colors.TEXT_HINT)
                    .backgroundColor(Color.Transparent).layoutWeight(1)
                    .onChange((v: string) => { this.nickname = v })
                }
                .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })

                Divider().color(Colors.DIVIDER).margin({ left: 16 })

                // 手机号 — 只读显示，点击触发验证码流程
                Row() {
                  Text('手机号').fontSize(15).fontColor(Colors.TEXT_PRIMARY).width(80)
                  Text(this.phone ? this.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : '未绑定')
                    .fontSize(15)
                    .fontColor(this.phone ? Colors.TEXT_PRIMARY : Colors.TEXT_HINT)
                    .layoutWeight(1)
                  Text('修改 >')
                    .fontSize(12)
                    .fontColor(Colors.TEXT_HINT)
                }
                .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })
                .onClick(() => { this.openVerifyDialog() })
              }
              .width('100%')
              .backgroundColor(Colors.BG_WHITE)
              .borderRadius(8)
              .margin({ left: 16, right: 16 })

              // 保存
              Button(this.saving ? '保存中...' : (this.uploading ? '上传头像中...' : '保存'))
                .fontSize(16)
                .backgroundColor((this.saving || this.uploading) ? Colors.TEXT_HINT : Colors.PRIMARY)
                .borderRadius(24).height(48).width('100%')
                .margin({ left: 16, right: 16, top: 40, bottom: 20 })
                .onClick(() => {
                  if (!this.saving && !this.uploading) { this.handleSave() }
                })
            }
          }
          .width('100%').layoutWeight(1).backgroundColor(Colors.BG_PAPER).scrollBar(BarState.Off)
        }
      }
      .width('100%').height('100%')

      // ======= 验证码弹窗 =======
      if (this.showVerifyModal) {
        this.VerifyCodeOverlay()
      }

      // ======= 新手机号弹窗 =======
      if (this.showNewPhoneModal) {
        this.NewPhoneOverlay()
      }
    }
    .width('100%').height('100%')
  }

  // 验证码弹窗
  @Builder
  VerifyCodeOverlay() {
    Column() {
      // 半透明遮罩
      Column()
        .width('100%').height('100%')
        .backgroundColor('#4D000000')
        .onClick(() => {
          this.showVerifyModal = false
          this.inputCode = ''
        })
    }

    // 弹窗内容
    Column() {
      Text('验证手机号')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.TEXT_PRIMARY)
        .margin({ top: 24, bottom: 8 })

      Text(`验证码已发送至 ${this.maskPhone(this.phone)}`)
        .fontSize(13)
        .fontColor(Colors.TEXT_SECONDARY)
        .margin({ bottom: 16 })

      // 模拟显示验证码
      Row() {
        Text('模拟验证码：')
          .fontSize(14)
          .fontColor(Colors.TEXT_SECONDARY)
        Text(this.verifyCode)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.PRIMARY)
          .letterSpacing(4)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(12)
      .backgroundColor(Colors.PRIMARY_BG)
      .borderRadius(8)
      .margin({ bottom: 16 })

      // 输入框
      TextInput({ placeholder: '请输入6位验证码' })
        .fontSize(16)
        .type(InputType.Number)
        .maxLength(6)
        .width('100%')
        .height(44)
        .backgroundColor(Colors.BG_PAPER)
        .borderRadius(8)
        .padding({ left: 12 })
        .onChange((v: string) => { this.inputCode = v })

      // 按钮行
      Row() {
        Button('取消')
          .fontSize(14)
          .backgroundColor(Colors.BG_PAPER)
          .fontColor(Colors.TEXT_SECONDARY)
          .borderRadius(20)
          .width('46%')
          .height(42)
          .onClick(() => {
            this.showVerifyModal = false
            this.inputCode = ''
          })

        Button('验证')
          .fontSize(14)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(20)
          .width('46%')
          .height(42)
          .onClick(() => { this.handleVerify() })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 20, bottom: 24 })
    }
    .width('84%')
    .padding({ left: 20, right: 20 })
    .backgroundColor(Colors.BG_WHITE)
    .borderRadius(16)
    .position({ x: '8%', y: '30%' })
  }

  // 新手机号弹窗
  @Builder
  NewPhoneOverlay() {
    Column() {
      // 半透明遮罩
      Column()
        .width('100%').height('100%')
        .backgroundColor('#4D000000')
        .onClick(() => {
          this.showNewPhoneModal = false
        })
    }

    Column() {
      Text('修改手机号')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.TEXT_PRIMARY)
        .margin({ top: 24, bottom: 16 })

      TextInput({ placeholder: '请输入新手机号' })
        .fontSize(16)
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .width('100%')
        .height(44)
        .backgroundColor(Colors.BG_PAPER)
        .borderRadius(8)
        .padding({ left: 12 })
        .onChange((v: string) => { this.newPhone = v })

      Row() {
        Button('取消')
          .fontSize(14)
          .backgroundColor(Colors.BG_PAPER)
          .fontColor(Colors.TEXT_SECONDARY)
          .borderRadius(20)
          .width('46%')
          .height(42)
          .onClick(() => { this.showNewPhoneModal = false })

        Button('确认修改')
          .fontSize(14)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(20)
          .width('46%')
          .height(42)
          .onClick(() => { this.handlePhoneChange() })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 20, bottom: 24 })
    }
    .width('84%')
    .padding({ left: 20, right: 20 })
    .backgroundColor(Colors.BG_WHITE)
    .borderRadius(16)
    .position({ x: '8%', y: '30%' })
  }

  // 打开验证码弹窗，生成随机6位码
  private openVerifyDialog(): void {
    this.inputCode = ''
    this.verifyCode = this.generateCode()
    this.showVerifyModal = true
  }

  private generateCode(): string {
    let code = ''
    for (let i = 0; i < 6; i++) {
      code += `${Math.floor(Math.random() * 10)}`
    }
    return code
  }

  private maskPhone(phone: string): string {
    if (phone.length >= 11) {
      return phone.substring(0, 3) + '****' + phone.substring(7)
    }
    return phone
  }

  private handleVerify(): void {
    if (this.inputCode !== this.verifyCode) {
      promptAction.showToast({ message: '验证码错误，请重新输入' })
      return
    }
    // 验证通过，切换到新手机号弹窗
    this.showVerifyModal = false
    this.inputCode = ''
    this.newPhone = ''
    this.showNewPhoneModal = true
  }

  private handlePhoneChange(): void {
    const phonePattern = /^1[3-9]\d{9}$/
    if (!phonePattern.test(this.newPhone.trim())) {
      promptAction.showToast({ message: '请输入正确的手机号' })
      return
    }
    this.phone = this.newPhone.trim()
    this.phoneChanged = true
    this.showNewPhoneModal = false
    promptAction.showToast({ message: '手机号修改成功' })
  }

  private async pickAvatar(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker()
      const result = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      })
      if (result.photoUris && result.photoUris.length > 0) {
        this.pendingAvatarUri = result.photoUris[0]
      }
    } catch (err) {
      // 用户取消选择
    }
  }

  private async handleSave(): Promise<void> {
    if (!this.nickname.trim()) {
      promptAction.showToast({ message: '请输入昵称' })
      return
    }

    this.saving = true

    let finalAvatar = this.avatar
    if (this.pendingAvatarUri) {
      this.uploading = true
      const uploadResp = await ApiClient.uploadFiles([this.pendingAvatarUri])
      this.uploading = false
      if (uploadResp.code === 0 && uploadResp.data) {
        const urls = uploadResp.data['urls']
        if (urls && urls.length > 0) {
          finalAvatar = urls[0]
        }
      } else {
        promptAction.showToast({ message: uploadResp.message || '头像上传失败' })
        this.saving = false
        return
      }
    }

    // 如果手机号被验证修改过，一起提交，否则不提交 phone 字段
    const body: Record<string, Object> = {}
    body['nickname'] = this.nickname.trim()
    body['avatar'] = finalAvatar
    if (this.phoneChanged) {
      body['phone'] = this.phone.trim()
    }

    const resp = await ApiClient.put<Object>('/users/1', body)
    this.saving = false

    if (resp.code === 0) {
      this.avatar = finalAvatar
      this.pendingAvatarUri = ''
      this.phoneChanged = false
      promptAction.showToast({ message: '保存成功' })
      router.back()
    } else {
      promptAction.showToast({ message: resp.message || '保存失败' })
    }
  }
}
