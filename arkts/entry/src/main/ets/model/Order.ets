// 订单数据模型
import { Address } from './Address'

export enum OrderStatus {
  PENDING_PAY = 0,      // 待付款
  PENDING_DELIVER = 1,  // 待发货
  PENDING_RECEIVE = 2,  // 待收货
  COMPLETED = 3,        // 已完成
  REFUNDING = 4         // 退款中
}

export function getOrderStatusText(status: OrderStatus): string {
  switch (status) {
    case OrderStatus.PENDING_PAY:
      return '待付款'
    case OrderStatus.PENDING_DELIVER:
      return '待发货'
    case OrderStatus.PENDING_RECEIVE:
      return '待收货'
    case OrderStatus.COMPLETED:
      return '已完成'
    case OrderStatus.REFUNDING:
      return '退款中'
    default:
      return '未知'
  }
}

export interface OrderItem {
  productId: string
  productName: string
  productImage: string
  skuId: string
  skuName: string
  price: number
  quantity: number
}

export interface Order {
  id: string
  orderNo: string
  status: OrderStatus
  items: OrderItem[]
  totalAmount: number
  discountAmount: number
  freight: number
  payAmount: number
  address: Address
  createTime: number
  payTime?: number
  deliverTime?: number
  finishTime?: number
}
