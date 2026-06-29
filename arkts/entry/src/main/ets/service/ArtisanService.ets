// 匠人服务 — 对接 Spring Boot ArtisanController
// 后端 ArtisanVO 字段与前端 Artisan 接口完全对齐（id 已是字符串），可直接反序列化。
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'
import { Artisan } from '../model/Artisan'
import { Product } from '../model/Product'

// 后端分页结构
interface ArtisanPage {
  list: Artisan[]
  total: number
  page: number
  size: number
}

export class ArtisanService {

  // 匠人列表（分页）
  static async fetchList(page: number = 1, size: number = 20, craftType?: string): Promise<ApiResponse<Artisan[]>> {
    const params: Record<string, string> = {}
    params['page'] = `${page}`
    params['size'] = `${size}`
    if (craftType) {
      params['craftType'] = craftType
    }
    const resp = await ApiClient.get<ArtisanPage>('/artisans', params)
    if (resp.code === 0 && resp.data && resp.data.list) {
      return { code: 0, message: 'ok', data: resp.data.list }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 热门匠人（首页推荐）
  static async fetchTop(limit: number = 6): Promise<ApiResponse<Artisan[]>> {
    const params: Record<string, string> = {}
    params['limit'] = `${limit}`
    const resp = await ApiClient.get<Artisan[]>('/artisans/top', params)
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 匠人详情
  static async fetchDetail(id: string): Promise<ApiResponse<Artisan | undefined>> {
    const resp = await ApiClient.get<Artisan>(`/artisans/${id}`)
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: undefined }
  }

  // 匠人的作品列表
  static async fetchProducts(id: string): Promise<ApiResponse<Product[]>> {
    const resp = await ApiClient.get<Product[]>(`/artisans/${id}/products`)
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 搜索匠人（按名称/技艺）
  static async searchArtisans(keyword: string): Promise<ApiResponse<Artisan[]>> {
    const params: Record<string, string> = { 'keyword': keyword }
    const resp = await ApiClient.get<Artisan[]>('/artisans/search', params)
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }
}
