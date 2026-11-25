// 收货地址数据模型

export interface Address {
  id: string
  name: string        // 收货人姓名
  phone: string       // 手机号
  province: string
  city: string
  district: string
  detail: string      // 详细地址
  isDefault: boolean
}
