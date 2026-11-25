// 编辑资料页面 — 修改头像/昵称/手机号（手机号需验证码验证后修改）
import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { Colors } from '../common/Colors'
import { NavBar } from '../components/NavBar'
import { ApiClient } from '../service/ApiClient'
import { User } from '../model/User'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct ProfileEdit {
  @State nickname: string = ''
  @State avatar: string = ''
  @State phone: string = ''
  @State saving: boolean = false
  @State uploading: boolean = false
  @State loading: boolean = true

  private pendingAvatarUri: string = ''

  @State showVerifyModal: boolean = false
  @State showNewPhoneModal: boolean = false
  @State verifyCode: string = ''
  @State inputCode: string = ''
  @State newPhone: string = ''
  private phoneChanged: boolean = false

  @StorageProp('theme') theme: ThemeMode = 'light'
  @StorageProp('fontScale') fontScale: FontScale = 'normal'
  @StorageProp('language') language: Language = 'zh'

  fs(n: number): number {
    return Math.round(n * (this.fontScale === 'small' ? 0.85 : this.fontScale === 'large' ? 1.2 : 1.0))
  }

  t(zh: string, en: string): string {
    return this.language === 'en' ? en : zh
  }

  aboutToAppear(): void {
    this.loadUser()
  }

  async loadUser(): Promise<void> {
    const resp = await ApiClient.get<User>('/users/me')
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
        NavBar({ title: this.t('编辑资料', 'Edit Profile'), showBack: true })

        if (this.loading) {
          Row() {
            LoadingProgress().width(24).height(24).color(Theme.primary(this.theme))
            Text(this.t('加载中...', 'Loading...')).fontSize(this.fs(14)).fontColor(Theme.textHint(this.theme)).margin({ left: 8 })
          }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.bg(this.theme))
        } else {
          Scroll() {
            Column() {
              // 头像
              Column() {
                Text(this.t('头像', 'Avatar'))
                  .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme)).width('100%')
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
                      .fontSize(this.fs(30))
                      .fontColor(Theme.WHITE)
                      .width(72)
                      .height(72)
                      .borderRadius(36)
                      .backgroundColor(Theme.primaryLight(this.theme))
                      .textAlign(TextAlign.Center)
                      .lineHeight(72)
                  }

                  Text(this.t('点击更换头像', 'Tap to change'))
                    .fontSize(this.fs(13)).fontColor(Theme.textHint(this.theme)).margin({ left: 16 })
                }
                .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .backgroundColor(Theme.card(this.theme))
                .borderRadius(8)
                .margin({ left: 16, right: 16 })
                .onClick(() => { this.pickAvatar() })
              }

              // 基本信息
              Text(this.t('基本信息', 'Basic Info'))
                .fontSize(this.fs(13)).fontColor(Theme.textSecondary(this.theme)).width('100%')
                .padding({ left: 16, right: 16, top: 24, bottom: 8 })

              Column() {
                Row() {
                  Text(this.t('昵称', 'Nickname')).fontSize(this.fs(15)).fontColor(Theme.textPrimary(this.theme)).width(80)
                  TextInput({ placeholder: this.t('请输入昵称', 'Enter nickname'), text: this.nickname })
                    .fontSize(this.fs(15)).fontColor(Theme.textPrimary(this.theme)).placeholderColor(Theme.textHint(this.theme))
                    .backgroundColor(Color.Transparent).layoutWeight(1)
                    .onChange((v: string) => { this.nickname = v })
                }
                .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })

                Divider().color(Theme.divider(this.theme)).margin({ left: 16 })

                Row() {
                  Text(this.t('手机号', 'Phone')).fontSize(this.fs(15)).fontColor(Theme.textPrimary(this.theme)).width(80)
                  Text(this.phone ? this.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2') : this.t('未绑定', 'Not bound'))
                    .fontSize(this.fs(15))
                    .fontColor(this.phone ? Theme.textPrimary(this.theme) : Theme.textHint(this.theme))
                    .layoutWeight(1)
                  Text(this.t('修改 >', 'Change >'))
                    .fontSize(this.fs(12))
                    .fontColor(Theme.textHint(this.theme))
                }
                .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })
                .onClick(() => { this.openVerifyDialog() })
              }
              .width('100%')
              .backgroundColor(Theme.card(this.theme))
              .borderRadius(8)
              .margin({ left: 16, right: 16 })

              // 保存
              Button(this.saving
                ? this.t('保存中...', 'Saving...')
                : (this.uploading ? this.t('上传头像中...', 'Uploading...') : this.t('保存', 'Save')))
                .fontSize(this.fs(16))
                .backgroundColor((this.saving || this.uploading) ? Theme.textHint(this.theme) : Theme.primary(this.theme))
                .borderRadius(24).height(48).width('100%')
                .margin({ left: 16, right: 16, top: 40, bottom: 20 })
                .onClick(() => {
                  if (!this.saving && !this.uploading) { this.handleSave() }
                })
            }
          }
          .width('100%').layoutWeight(1).backgroundColor(Theme.bg(this.theme)).scrollBar(BarState.Off)
        }
      }
      .width('100%').height('100%')
      .backgroundColor(Theme.bg(this.theme))

      if (this.showVerifyModal) {
        this.VerifyCodeOverlay()
      }

      if (this.showNewPhoneModal) {
        this.NewPhoneOverlay()
      }
    }
    .width('100%').height('100%')
  }

  @Builder
  VerifyCodeOverlay() {
    Column() {
      Column()
        .width('100%').height('100%')
        .backgroundColor('#4D000000')
        .onClick(() => {
          this.showVerifyModal = false
          this.inputCode = ''
        })
    }

    Column() {
      Text(this.t('验证手机号', 'Verify Phone'))
        .fontSize(this.fs(18))
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.textPrimary(this.theme))
        .margin({ top: 24, bottom: 8 })

      Text(`${this.t('验证码已发送至', 'Code sent to')} ${this.maskPhone(this.phone)}`)
        .fontSize(this.fs(13))
        .fontColor(Theme.textSecondary(this.theme))
        .margin({ bottom: 16 })

      Row() {
        Text(this.t('模拟验证码：', 'Test code: '))
          .fontSize(this.fs(14))
          .fontColor(Theme.textSecondary(this.theme))
        Text(this.verifyCode)
          .fontSize(this.fs(22))
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.primary(this.theme))
          .letterSpacing(4)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(12)
      .backgroundColor(Theme.primaryBg(this.theme))
      .borderRadius(8)
      .margin({ bottom: 16 })

      TextInput({ placeholder: this.t('请输入6位验证码', 'Enter 6-digit code') })
        .fontSize(this.fs(16))
        .type(InputType.Number)
        .maxLength(6)
        .width('100%')
        .height(44)
        .backgroundColor(Theme.bg(this.theme))
        .borderRadius(8)
        .padding({ left: 12 })
        .onChange((v: string) => { this.inputCode = v })

      Row() {
        Button(this.t('取消', 'Cancel'))
          .fontSize(this.fs(14))
          .backgroundColor(Theme.bg(this.theme))
          .fontColor(Theme.textSecondary(this.theme))
          .borderRadius(20)
          .width('46%')
          .height(42)
          .onClick(() => {
            this.showVerifyModal = false
            this.inputCode = ''
          })

        Button(this.t('验证', 'Verify'))
          .fontSize(this.fs(14))
          .backgroundColor(Theme.primary(this.theme))
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
    .backgroundColor(Theme.card(this.theme))
    .borderRadius(16)
    .position({ x: '8%', y: '30%' })
  }

  @Builder
  NewPhoneOverlay() {
    Column() {
      Column()
        .width('100%').height('100%')
        .backgroundColor('#4D000000')
        .onClick(() => {
          this.showNewPhoneModal = false
        })
    }

    Column() {
      Text(this.t('修改手机号', 'Change Phone'))
        .fontSize(this.fs(18))
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.textPrimary(this.theme))
        .margin({ top: 24, bottom: 16 })

      TextInput({ placeholder: this.t('请输入新手机号', 'Enter new phone number') })
        .fontSize(this.fs(16))
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .width('100%')
        .height(44)
        .backgroundColor(Theme.bg(this.theme))
        .borderRadius(8)
        .padding({ left: 12 })
        .onChange((v: string) => { this.newPhone = v })

      Row() {
        Button(this.t('取消', 'Cancel'))
          .fontSize(this.fs(14))
          .backgroundColor(Theme.bg(this.theme))
          .fontColor(Theme.textSecondary(this.theme))
          .borderRadius(20)
          .width('46%')
          .height(42)
          .onClick(() => { this.showNewPhoneModal = false })

        Button(this.t('确认修改', 'Confirm'))
          .fontSize(this.fs(14))
          .backgroundColor(Theme.primary(this.theme))
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
    .backgroundColor(Theme.card(this.theme))
    .borderRadius(16)
    .position({ x: '8%', y: '30%' })
  }

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
      promptAction.showToast({ message: this.t('验证码错误，请重新输入', 'Wrong code, try again') })
      return
    }
    this.showVerifyModal = false
    this.inputCode = ''
    this.newPhone = ''
    this.showNewPhoneModal = true
  }

  private handlePhoneChange(): void {
    const phonePattern = /^1[3-9]\d{9}$/
    if (!phonePattern.test(this.newPhone.trim())) {
      promptAction.showToast({ message: this.t('请输入正确的手机号', 'Please enter a valid phone number') })
      return
    }
    this.phone = this.newPhone.trim()
    this.phoneChanged = true
    this.showNewPhoneModal = false
    promptAction.showToast({ message: this.t('手机号修改成功', 'Phone updated') })
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
      promptAction.showToast({ message: this.t('请输入昵称', 'Please enter a nickname') })
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
        promptAction.showToast({ message: uploadResp.message || this.t('头像上传失败', 'Avatar upload failed') })
        this.saving = false
        return
      }
    }

    const body: Record<string, Object> = {}
    body['nickname'] = this.nickname.trim()
    body['avatar'] = finalAvatar
    if (this.phoneChanged) {
      body['phone'] = this.phone.trim()
    }

    const resp = await ApiClient.put<Object>('/users/profile', body)
    this.saving = false

    if (resp.code === 0) {
      this.avatar = finalAvatar
      this.pendingAvatarUri = ''
      this.phoneChanged = false
      promptAction.showToast({ message: this.t('保存成功', 'Saved') })
      router.back()
    } else {
      promptAction.showToast({ message: resp.message || this.t('保存失败', 'Save failed') })
    }
  }
}
