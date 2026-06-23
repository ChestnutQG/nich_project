// 订单服务 — 支持 Mock / Spring Boot 双模式切换
import { Order, OrderStatus } from '../model/Order'
import { ApiResponse } from '../model/ApiResponse'
import { ApiClient } from './ApiClient'

const USE_MOCK = false

function delay(ms: number = 400): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

const mockOrders: Order[] = [
  {
    id: 'o001',
    orderNo: '20240615142033001',
    status: OrderStatus.PENDING_RECEIVE,
    items: [
      {
        productId: 'p001',
        productName: '苏绣双面绣团扇 · 蝶恋花',
        productImage: 'https://picsum.photos/seed/nh01/200/200',
        skuId: 'sku001',
        skuName: '团扇·蝶恋花',
        price: 128000,
        quantity: 1
      }
    ],
    totalAmount: 128000,
    discountAmount: 0,
    freight: 0,
    payAmount: 128000,
    address: {
      id: 'addr001',
      name: '张明',
      phone: '13912345678',
      province: '北京市',
      city: '北京市',
      district: '朝阳区',
      detail: '建国路88号SOHO现代城A座1201',
      isDefault: true
    },
    createTime: 1718419200000,
    payTime: 1718421000000,
    deliverTime: 1718505600000
  }
]

export class OrderService {
  static async fetchOrders(status?: OrderStatus, userId?: string): Promise<ApiResponse<Order[]>> {
    if (USE_MOCK) {
      await delay()
      let list = mockOrders
      if (status !== undefined) {
        list = mockOrders.filter(o => o.status === status)
      }
      return { code: 0, message: 'ok', data: list }
    }
    const params: Record<string, string> = {}
    params['userId'] = userId || '1'
    if (status !== undefined && status >= 0) {
      params['status'] = `${status}`
    }
    return ApiClient.get<Order[]>('/orders', params)
  }

  static async fetchOrderDetail(id: string): Promise<ApiResponse<Order | undefined>> {
    if (USE_MOCK) {
      await delay()
      return { code: 0, message: 'ok', data: mockOrders.find(o => o.id === id) }
    }
    return ApiClient.get<Order>(`/orders/${id}`)
  }

  static async createOrder(order: Order): Promise<ApiResponse<Order>> {
    if (USE_MOCK) {
      await delay(800)
      return { code: 0, message: '下单成功', data: order }
    }
    return ApiClient.post<Order>('/orders', order)
  }
}
