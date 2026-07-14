// 购物车服务 — 对接 Spring Boot CartController
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'

export interface CartItem {
  id: string
  productId: string
  productName: string
  productImage: string
  artisanName: string
  skuId: string
  skuName: string
  price: number
  quantity: number
  isChecked: boolean
  stock: number
}

// 请求体类型（ArkTS 要求显式声明）
interface AddCartReq {
  productId: string
  skuId: string
  quantity: number
  productName: string
  productImage: string
  artisanName: string
  skuName: string
  price: number
}

interface QtyReq {
  quantity: number
}

interface CheckedReq {
  isChecked: number
}

let cachedCount: number = 0

export class CartService {

  static async fetchCartList(): Promise<ApiResponse<CartItem[]>> {
    const resp = await ApiClient.get<CartItem[]>('/cart')
    if (resp.code === 0) {
      cachedCount = resp.data.length
    }
    return resp
  }

  static async addToCart(productId: string, skuId: string, quantity: number,
                          productName: string, productImage: string,
                          artisanName: string, skuName: string, price: number): Promise<ApiResponse<null>> {
    const body: AddCartReq = { productId, skuId, quantity, productName, productImage, artisanName, skuName, price }
    const resp = await ApiClient.post<null>('/cart', body)
    if (resp.code === 0) {
      CartService.refreshCount()
    }
    return resp
  }

  static async updateQuantity(cartItemId: string, quantity: number): Promise<ApiResponse<null>> {
    const body: QtyReq = { quantity }
    return await ApiClient.put<null>(`/cart/${cartItemId}`, body)
  }

  static async updateChecked(cartItemId: string, isChecked: number): Promise<ApiResponse<null>> {
    const body: CheckedReq = { isChecked }
    return await ApiClient.put<null>(`/cart/${cartItemId}/checked`, body)
  }

  static async updateAllChecked(isChecked: number): Promise<ApiResponse<null>> {
    const body: CheckedReq = { isChecked }
    return await ApiClient.put<null>('/cart/check-all', body)
  }

  static async removeItem(cartItemId: string): Promise<ApiResponse<null>> {
    const resp = await ApiClient.del<null>(`/cart/${cartItemId}`)
    if (resp.code === 0) {
      CartService.refreshCount()
    }
    return resp
  }

  static async refreshCount(): Promise<void> {
    const resp = await ApiClient.get<number>('/cart/count')
    if (resp.code === 0) {
      cachedCount = resp.data as number || 0
    }
  }

  static getCartCount(): number {
    return cachedCount
  }

  static async loadCartCount(): Promise<number> {
    await CartService.refreshCount()
    return cachedCount
  }
}
