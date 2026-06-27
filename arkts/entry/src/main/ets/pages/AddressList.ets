// 收货地址管理页
import { promptAction, router } from '@kit.ArkUI'
import { Colors } from '../common/Colors'
import { Address } from '../model/Address'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'
import { AddressService, AddressPayload } from '../service/AddressService'

@Entry
@Component
struct AddressList {
  @State addresses: Address[] = []
  @State loading: boolean = true
  @State selectMode: boolean = false   // 从订单确认页进入时为“选择地址”模式

  // 新增/编辑表单
  @State showForm: boolean = false
  @State editingId: string = ''   // 空表示新增
  @State fName: string = ''
  @State fPhone: string = ''
  @State fProvince: string = ''
  @State fCity: string = ''
  @State fDistrict: string = ''
  @State fDetail: string = ''
  @State fDefault: boolean = false
  @State saving: boolean = false

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.selectMode = params != null && params['mode'] === 'select'
    this.loadAddresses()
  }

  // 选中某条地址，回传给订单确认页
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
      promptAction.showToast({ message: resp.message || '加载失败' })
    }
    this.loading = false
  }

  build() {
    Stack() {
      Column() {
        NavBar({ title: this.selectMode ? '选择收货地址' : '收货地址', showBack: true })

        if (this.addresses.length === 0 && !this.loading) {
          EmptyState({ message: '还没有收货地址', iconText: '📍' })
        } else {
          Scroll() {
            Column() {
              ForEach(this.addresses, (addr: Address) => {
                Column() {
                  Row() {
                    Text(addr.name)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Colors.TEXT_PRIMARY)
                    Text(addr.phone)
                      .fontSize(13)
                      .fontColor(Colors.TEXT_SECONDARY)
                      .margin({ left: 16 })
                    Blank()
                    if (addr.isDefault) {
                      Text('默认')
                        .fontSize(10)
                        .fontColor(Colors.PRIMARY)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(4)
                        .border({ width: 1, color: Colors.PRIMARY })
                    }
                  }
                  .width('100%')

                  Text(`${addr.province}${addr.city}${addr.district} ${addr.detail}`)
                    .fontSize(13)
                    .fontColor(Colors.TEXT_SECONDARY)
                    .margin({ top: 6 })
                    .width('100%')

                  if (!this.selectMode) {
                    Row() {
                      if (!addr.isDefault) {
                        Text('设为默认')
                          .fontSize(12)
                          .fontColor(Colors.TEXT_HINT)
                          .onClick(() => { this.setDefault(addr) })
                      }
                      Blank()
                      Text('编辑')
                        .fontSize(12)
                        .fontColor(Colors.TEXT_HINT)
                        .onClick(() => { this.openForm(addr) })
                      Text('删除')
                        .fontSize(12)
                        .fontColor('#C23B33')
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
                .backgroundColor(Colors.BG_WHITE)
                .margin({ left: 16, right: 16, top: 10 })
                .onClick(() => {
                  if (this.selectMode) { this.pickAddress(addr) }
                })
              })
            }
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor(Colors.BG_PAPER)
          .scrollBar(BarState.Off)
        }

        // 新增地址按钮
        Button('+ 新增收货地址')
          .fontSize(15)
          .fontColor(Colors.BG_WHITE)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(24)
          .height(44)
          .width('90%')
          .margin({ bottom: 20 })
          .onClick(() => { this.openForm(null) })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Colors.BG_PAPER)

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
        Text(this.editingId ? '编辑地址' : '新增地址')
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor(Colors.TEXT_PRIMARY)
          .margin({ bottom: 16 })

        Row() {
          Text('收货人').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(80)
          TextInput({ text: this.fName }).fontSize(14).fontColor(Colors.TEXT_PRIMARY)
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fName = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })

        Row() {
          Text('手机号').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(80)
          TextInput({ text: this.fPhone }).fontSize(14).fontColor(Colors.TEXT_PRIMARY)
            .backgroundColor(Color.Transparent).layoutWeight(1).type(InputType.PhoneNumber)
            .onChange((v: string) => { this.fPhone = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })

        Row() {
          Text('省份').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(80)
          TextInput({ text: this.fProvince }).fontSize(14).fontColor(Colors.TEXT_PRIMARY)
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fProvince = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })

        Row() {
          Text('城市').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(80)
          TextInput({ text: this.fCity }).fontSize(14).fontColor(Colors.TEXT_PRIMARY)
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fCity = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })

        Row() {
          Text('区县').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(80)
          TextInput({ text: this.fDistrict }).fontSize(14).fontColor(Colors.TEXT_PRIMARY)
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fDistrict = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })

        Row() {
          Text('详细地址').fontSize(14).fontColor(Colors.TEXT_PRIMARY).width(80)
          TextInput({ text: this.fDetail }).fontSize(14).fontColor(Colors.TEXT_PRIMARY)
            .backgroundColor(Color.Transparent).layoutWeight(1)
            .onChange((v: string) => { this.fDetail = v })
        }
        .width('100%').padding({ top: 10, bottom: 10 })
        .border({ width: { bottom: 0.5 }, color: Colors.DIVIDER })

        Row() {
          Text('设为默认地址').fontSize(14).fontColor(Colors.TEXT_PRIMARY).layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.fDefault })
            .selectedColor(Colors.PRIMARY)
            .onChange((v: boolean) => { this.fDefault = v })
        }
        .width('100%').margin({ top: 8, bottom: 16 })

        Button(this.saving ? '保存中...' : '保存')
          .width('100%').height(46)
          .fontSize(16).fontColor(Colors.BG_WHITE)
          .backgroundColor(Colors.PRIMARY).borderRadius(23)
          .enabled(!this.saving)
          .onClick(() => { this.saveAddress() })
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Colors.BG_WHITE)
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
      promptAction.showToast({ message: '请填写收货人、手机号和详细地址' })
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
      promptAction.showToast({ message: '保存成功' })
      this.loadAddresses()
    } else {
      promptAction.showToast({ message: resp.message || '保存失败' })
    }
  }

  private async setDefault(item: Address): Promise<void> {
    // 没有独立的设默认接口，提交整条地址并把 isDefault 置 1
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
      promptAction.showToast({ message: resp.message || '操作失败' })
    }
  }

  private async deleteAddress(item: Address): Promise<void> {
    const resp = await AddressService.remove(item.id)
    if (resp.code === 0) {
      promptAction.showToast({ message: '已删除' })
      this.loadAddresses()
    } else {
      promptAction.showToast({ message: resp.message || '删除失败' })
    }
  }
}
