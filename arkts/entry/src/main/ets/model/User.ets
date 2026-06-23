// 用户数据模型

export interface User {
  id: string
  nickname: string
  avatar: string
  phone: string
  collectCount: number    // 收藏商品数
  followCount: number     // 关注匠人数
  orderCount: number      // 订单数
}
