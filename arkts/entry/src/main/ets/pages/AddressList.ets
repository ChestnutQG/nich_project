// 收货地址管理页
import { promptAction, router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Address } from '../model/Address'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'
import { AddressService, AddressPayload } from '../service/AddressService'
import { Theme } from '../common/Theme'
import { ThemeMode, FontScale, Language } from '../service/SettingsService'

@Entry
@Component
struct AddressList {
  @State addresses: Address[] = []
  @State loading: boolean = true
  @State selectMode: boolean = false

  @State showForm: boolean = false
  @State editingId: string = ''
  @State fName: string = ''
  @State fPhone: string = ''
  @State fProvince: string = ''
  @State fCity: string = ''
  @State fDistrict: string = ''
  @State fDetail: string = ''
  @State fDefault: boolean = false
  @State saving: boolean = false

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
    const params = router.getParams() as Record<string, string>
    this.selectMode = params != null && params['mode'] === 'select'
    this.loadAddresses()
  }

  private pickAddress(addr: Address): void {
    AppStorage.setOrCreate('orderSelectedAddressId', addr.id)
    router.back()
  }

  async loadAddresses(): Promise<void> {
    this.loading = true
    const resp = await AddressService.fetchList()
    if (resp.code === 0) {
      this.addresses = resp.data
    } else {
      promptAction.showToast({ message: resp.message || this.t('加载失败', 'Load failed') })
    }
    this.loading = false
  }

  build() {
    Stack() {
      Column() {
        NavBar({
          title: this.selectMode ? this.t('选择收货地址', 'Select Address') : this.t('收货地址', 'My Addresses'),
          showBack: true
        })

        if (this.addresses.length === 0 && !this.loading) {
          EmptyState({ message: this.t('还没有收货地址', 'No addresses yet'), iconText: '📍' })
        } else {
          Scroll() {
            Column() {
              ForEach(this.addresses, (addr: Address) => {
                Column() {
                  Row() {
                    Text(addr.name)
                      .fontSize(this.fs(15))
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.textPrimary(this.theme))
                    Text(addr.phone)
                      .fontSize(this.fs(13))
                      .fontColor(Theme.textSecondary(this.theme))
                      .margin({ left: 16 })
                    Blank()
                    if (addr.isDefault) {
                      Text(this.t('默认', 'Default'))
                        .fontSize(this.fs(10))
                        .fontColor(Theme.primary(this.theme))
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(4)
                        .border({ width: 1, color: Theme.primary(this.theme) })
                    }
                  }
                  .width('100%')

                  Text(`${addr.province}${addr.city}${addr.district} ${addr.detail}`)
                    .fontSize(this.fs(13))
                    .fontColor(Theme.textSecondary(this.theme))
                    .margin({ top: 6 })
                    .width('100%')

                  if (!this.selectMode) {
                    Row() {
                      if (!addr.isDefault) {
                        Text(this.t('设为默认', 'Set Default'))
                          .fontSize(this.fs(12))
                          .fontColor(Theme.textHint(this.theme))
                          .onClick(() => { this.setDefault(addr) })
                      }
                      Blank()
                      Text(this.t('编辑', 'Edit'))
                        .fontSize(this.fs(12))
                        .fontColor(Theme.textHint(this.theme))
                        .onClick(() => { this.openForm(addr) })
                      Text(this.t('删除', 'Delete'))
                        .fontSize(this.fs(12))
                        .fontColor(Theme.error(this.theme))
                        .margin({ left: 20 })
                        .onClick(() => { this.deleteAddress(addr) })
                    }
                    .width('100%')
                    .margin({ top: 10 })
                  }
                }
                .width('100%')
                .padding(16)
                .borderRadius(8)
                .backgroundColor(Theme.card(this.theme))
                .margin({ left: 16, right: 16, top: 10 })
                .onClick(() => {
                  if (this.selectMode) { this.pickAddress(addr) }
                })
              })
            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor(Theme.bg(this.theme))
          .scrollBar(BarState.Off)
        }

        Button(`+ ${this.t('新增收货地址', 'Add Address')}`)
          .fontSize(this.fs(15))
          .fontColor(Theme.WHITE)
          .backgroundColor(Theme.primary(this.theme))
          .borderRadius(24)
          .height(44)
          .width('90%')
          .margin({ bottom: 20 })
          .onClick(() => { this.openForm(null) })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.bg(this.theme))

      if (this.showForm) {
        this.FormPanel()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FormPanel() {
    Column() {
      Column()
        .width('100%').layoutWeight(1).backgroundColor('#55000000')
        .onClick(() => { this.showForm = false })

      Column() {
        Text(this.editingId ? this.t('编辑地址', 'Edit Address') : this.t('新增地址', 'Add Address'))
          .fontSize(this.fs(16)).fontWeight(FontWeight.Bold).fontColor(Theme.textPrimary(this.theme))
          .margin({ bottom: 16 })

        Row() {
          Text(this.t('收货人', 'Name')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(80)
          TextInput({ text: this.fName }).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fName = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Theme.divider(this.theme) })

        Row() {
          Text(this.t('手机号', 'Phone')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(80)
          TextInput({ text: this.fPhone }).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
            .backgroundColor(Color.Transparent).layoutWeight(1).type(InputType.PhoneNumber)
            .onChange((v: string) => { this.fPhone = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Theme.divider(this.theme) })

        Row() {
          Text(this.t('省份', 'Province')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(80)
          TextInput({ text: this.fProvince }).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fProvince = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Theme.divider(this.theme) })

        Row() {
          Text(this.t('城市', 'City')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(80)
          TextInput({ text: this.fCity }).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fCity = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Theme.divider(this.theme) })

        Row() {
          Text(this.t('区县', 'District')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(80)
          TextInput({ text: this.fDistrict }).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fDistrict = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Theme.divider(this.theme) })

        Row() {
          Text(this.t('详细地址', 'Detail')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).width(80)
          TextInput({ text: this.fDetail }).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme))
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fDetail = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Theme.divider(this.theme) })

        Row() {
          Text(this.t('设为默认地址', 'Set as default')).fontSize(this.fs(14)).fontColor(Theme.textPrimary(this.theme)).layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.fDefault })
            .selectedColor(Theme.primary(this.theme))
            .onChange((v: boolean) => { this.fDefault = v })
        }
        .width('100%').margin({ top: 8, bottom: 16 })

        Button(this.saving ? this.t('保存中...', 'Saving...') : this.t('保存', 'Save'))
          .width('100%').height(46)
          .fontSize(this.fs(16)).fontColor(Theme.WHITE)
          .backgroundColor(Theme.primary(this.theme)).borderRadius(23)
          .enabled(!this.saving)
          .onClick(() => { this.saveAddress() })
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Theme.card(this.theme))
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%').height('100%')
  }

  private openForm(item: Address | null): void {
    if (item) {
      this.editingId = item.id
      this.fName = item.name
      this.fPhone = item.phone
      this.fProvince = item.province
      this.fCity = item.city
      this.fDistrict = item.district
      this.fDetail = item.detail
      this.fDefault = item.isDefault
    } else {
      this.editingId = ''
      this.fName = ''
      this.fPhone = ''
      this.fProvince = ''
      this.fCity = ''
      this.fDistrict = ''
      this.fDetail = ''
      this.fDefault = false
    }
    this.showForm = true
  }

  private async saveAddress(): Promise<void> {
    if (!this.fName.trim() || !this.fPhone.trim() || !this.fDetail.trim()) {
      promptAction.showToast({ message: this.t('请填写收货人、手机号和详细地址', 'Please fill in name, phone and address') })
      return
    }
    const payload: AddressPayload = {
      name: this.fName.trim(),
      phone: this.fPhone.trim(),
      province: this.fProvince.trim(),
      city: this.fCity.trim(),
      district: this.fDistrict.trim(),
      detail: this.fDetail.trim(),
      isDefault: this.fDefault ? 1 : 0
    }
    if (this.editingId) {
      payload.id = parseInt(this.editingId)
    }
    this.saving = true
    const resp = await AddressService.save(payload)
    this.saving = false
    if (resp.code === 0) {
      this.showForm = false
      promptAction.showToast({ message: this.t('保存成功', 'Saved') })
      this.loadAddresses()
    } else {
      promptAction.showToast({ message: resp.message || this.t('保存失败', 'Save failed') })
    }
  }

  private async setDefault(item: Address): Promise<void> {
    const payload: AddressPayload = {
      id: parseInt(item.id),
      name: item.name,
      phone: item.phone,
      province: item.province,
      city: item.city,
      district: item.district,
      detail: item.detail,
      isDefault: 1
    }
    const resp = await AddressService.save(payload)
    if (resp.code === 0) {
      this.loadAddresses()
    } else {
      promptAction.showToast({ message: resp.message || this.t('操作失败', 'Failed') })
    }
  }

  private async deleteAddress(item: Address): Promise<void> {
    const resp = await AddressService.remove(item.id)
    if (resp.code === 0) {
      promptAction.showToast({ message: this.t('已删除', 'Deleted') })
      this.loadAddresses()
    } else {
      promptAction.showToast({ message: resp.message || this.t('删除失败', 'Delete failed') })
    }
  }
}
