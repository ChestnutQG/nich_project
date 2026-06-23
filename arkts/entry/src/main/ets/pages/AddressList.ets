// 收货地址管理页
import { Colors } from '../common/Colors'
import { Address } from '../model/Address'
import { NavBar } from '../components/NavBar'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct AddressList {
  @State addresses: Address[] = [
    {
      id: 'addr001',
      name: '张明',
      phone: '13912345678',
      province: '北京市',
      city: '北京市',
      district: '朝阳区',
      detail: '建国路88号SOHO现代城A座1201',
      isDefault: true
    }
  ]

  build() {
    Column() {
      NavBar({ title: '收货地址', showBack: true })

      if (this.addresses.length === 0) {
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

                Row() {
                  Text('设为默认')
                    .fontSize(12)
                    .fontColor(Colors.TEXT_HINT)
                    .onClick(() => {
                      this.addresses.forEach(a => a.isDefault = false)
                      addr.isDefault = true
                    })
                  Text('编辑')
                    .fontSize(12)
                    .fontColor(Colors.TEXT_HINT)
                    .margin({ left: 20 })
                  Text('删除')
                    .fontSize(12)
                    .fontColor('#C23B33')
                    .margin({ left: 20 })
                    .onClick(() => {
                      const idx = this.addresses.findIndex(a => a.id === addr.id)
                      if (idx >= 0) this.addresses.splice(idx, 1)
                    })
                }
                .width('100%')
                .margin({ top: 10 })
              }
              .width('100%')
              .padding(16)
              .borderRadius(8)
              .backgroundColor(Colors.BG_WHITE)
              .margin({ left: 16, right: 16, top: 10 })
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
        .backgroundColor(Colors.PRIMARY)
        .borderRadius(24)
        .height(44)
        .width('90%')
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }
}
