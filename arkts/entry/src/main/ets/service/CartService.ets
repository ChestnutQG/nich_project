// 购物车服务（本地存储 + Mock）
import { ApiResponse } from '../model/ApiResponse'

export interface CartItem {
  productId: string
  productName: string
  productImage: string
  artisanName: string
  skuId: string
  skuName: string
  price: number       // 分
  quantity: number
  checked: boolean
}

function delay(ms: number = 200): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

// 购物车数据存在内存中（后续接入 PersistenStorage）
const cartItems: CartItem[] = []

export class CartService {
  static async fetchCartList(): Promise<ApiResponse<CartItem[]>> {
    await delay()
    return { code: 0, message: 'ok', data: [...cartItems] }
  }

  static async addToCart(item: CartItem): Promise<ApiResponse<null>> {
    const exist = cartItems.find(i => i.skuId === item.skuId)
    if (exist) {
      exist.quantity += item.quantity
    } else {
      cartItems.push(item)
    }
    await delay()
    return { code: 0, message: '已加入购物车', data: null }
  }

  static async updateQuantity(skuId: string, quantity: number): Promise<ApiResponse<null>> {
    await delay(100)
    const item = cartItems.find(i => i.skuId === skuId)
    if (item && quantity > 0) {
      item.quantity = quantity
    }
    return { code: 0, message: 'ok', data: null }
  }

  static async updateChecked(skuId: string, checked: boolean): Promise<ApiResponse<null>> {
    await delay(100)
    const item = cartItems.find(i => i.skuId === skuId)
    if (item) {
      item.checked = checked
    }
    return { code: 0, message: 'ok', data: null }
  }

  static async updateAllChecked(checked: boolean): Promise<ApiResponse<null>> {
    await delay(100)
    cartItems.forEach(i => i.checked = checked)
    return { code: 0, message: 'ok', data: null }
  }

  static async removeItem(skuId: string): Promise<ApiResponse<null>> {
    await delay(200)
    const idx = cartItems.findIndex(i => i.skuId === skuId)
    if (idx >= 0) {
      cartItems.splice(idx, 1)
    }
    return { code: 0, message: '已移除', data: null }
  }

  static getCartCount(): number {
    return cartItems.length
  }
}
