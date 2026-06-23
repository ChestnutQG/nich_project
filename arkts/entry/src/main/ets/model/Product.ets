// 商品数据模型

export interface Sku {
  id: string
  name: string        // 规格名称，如"中号·青花色"
  price: number       // 单位：分
  stock: number
  image: string
}

export interface CraftStep {
  title: string
  image: string
  description: string
}

export interface Product {
  id: string
  name: string
  description: string
  categoryId: string
  categoryName: string
  artisanId: string
  artisanName: string
  images: string[]
  price: number          // 现价，单位：分
  originalPrice: number  // 原价，单位：分
  stock: number
  sales: number
  region: string         // 产地
  craftType: string      // 技艺类型
  story: string          // 文化故事，富文本 HTML
  craftProcess: CraftStep[]
  skus: Sku[]
  rating: number         // 评分 1-5
  tags: string[]
  isCollect: boolean
  createTime: number
}
