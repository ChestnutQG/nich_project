// 收货地址服务 — 对接 Spring Boot AddressController
// 后端只有 GET（列表）/ POST（新增或更新，靠有无 id 区分）/ DELETE 三个接口，
// isDefault 用 0/1 整数表示，设为默认也走 POST（带 id + isDefault=1）。
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'
import { Address } from '../model/Address'

// 后端原始结构（id、isDefault 都是数字）
interface RawAddress {
  id: number
  name: string
  phone: string
  province: string
  city: string
  district: string
  detail: string
  isDefault: number
}

// 提交给后端的地址数据，id 为空表示新增
export interface AddressPayload {
  id?: number
  name: string
  phone: string
  province: string
  city: string
  district: string
  detail: string
  isDefault: number
}

function normalize(raw: RawAddress): Address {
  return {
    id: `${raw.id}`,
    name: raw.name || '',
    phone: raw.phone || '',
    province: raw.province || '',
    city: raw.city || '',
    district: raw.district || '',
    detail: raw.detail || '',
    isDefault: raw.isDefault === 1
  }
}

export class AddressService {

  // 我的地址列表
  static async fetchList(): Promise<ApiResponse<Address[]>> {
    const resp = await ApiClient.get<RawAddress[]>('/addresses')
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data.map(normalize) }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 新增或更新（带 id 即更新）
  static async save(payload: AddressPayload): Promise<ApiResponse<number>> {
    return ApiClient.post<number>('/addresses', payload)
  }

  // 删除
  static async remove(id: string): Promise<ApiResponse<null>> {
    return ApiClient.del<null>(`/addresses/${id}`)
  }
}
