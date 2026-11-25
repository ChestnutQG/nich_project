// 收藏服务 — 对接 Spring Boot FavoriteController
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'
import { Product } from '../model/Product'

interface FavReq {
  productId: number
}

export class FavoriteService {

  // 我的收藏列表
  static async fetchMyFavorites(): Promise<ApiResponse<Product[]>> {
    const resp = await ApiClient.get<Product[]>('/favorites')
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 添加收藏
  static async add(productId: string): Promise<ApiResponse<null>> {
    const body: FavReq = { productId: parseInt(productId) }
    return ApiClient.post<null>('/favorites', body)
  }

  // 取消收藏
  static async remove(productId: string): Promise<ApiResponse<null>> {
    return ApiClient.del<null>(`/favorites/${productId}`)
  }
}
