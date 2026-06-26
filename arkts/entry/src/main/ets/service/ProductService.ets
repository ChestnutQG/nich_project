// 商品服务 — 支持 Mock / Spring Boot 双模式切换
import { Product } from '../model/Product'
import { ApiResponse, PagedData } from '../model/ApiResponse'
import { ApiClient } from './ApiClient'
import { MockProducts, getRecommendProducts, getProductsByCategory, getProductById } from '../mock/MockProducts'

// 开发阶段使用 Mock 数据，后端联调时设为 false
const USE_MOCK = false

// Mock 延迟
function delay(ms: number = 300): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

export class ProductService {

  // 首页推荐
  static async fetchRecommendProducts(): Promise<ApiResponse<Product[]>> {
    if (USE_MOCK) {
      await delay()
      return { code: 0, message: 'ok', data: getRecommendProducts() }
    }
    return ApiClient.get<Product[]>('/products/recommend')
  }

  // 分页列表
  static async fetchProductList(
    page: number = 1,
    pageSize: number = 10,
    categoryId?: string,
    sortBy?: string
  ): Promise<ApiResponse<PagedData<Product>>> {
    if (USE_MOCK) {
      await delay()
      let list = MockProducts
      if (categoryId) {
        list = getProductsByCategory(categoryId)
      }
      if (sortBy === 'price_asc') {
        list = [...list].sort((a, b) => a.price - b.price)
      } else if (sortBy === 'price_desc') {
        list = [...list].sort((a, b) => b.price - a.price)
      } else if (sortBy === 'sales') {
        list = [...list].sort((a, b) => b.sales - a.sales)
      }
      const start = (page - 1) * pageSize
      const paged = list.slice(start, start + pageSize)
      const pagedData: PagedData<Product> = { list: paged, total: list.length, page, pageSize }
      return { code: 0, message: 'ok', data: pagedData }
    }
    const queryParams: Record<string, string> = {}
    queryParams['page'] = `${page}`
    queryParams['pageSize'] = `${pageSize}`
    if (categoryId) {
      queryParams['categoryId'] = categoryId
    }
    if (sortBy) {
      queryParams['sortBy'] = sortBy
    }
    return ApiClient.get<PagedData<Product>>('/products', queryParams)
  }

  // 商品详情
  static async fetchProductDetail(id: string): Promise<ApiResponse<Product | undefined>> {
    if (USE_MOCK) {
      await delay()
      return { code: 0, message: 'ok', data: getProductById(id) }
    }
    return ApiClient.get<Product>(`/products/${id}`)
  }

  // 搜索
  static async searchProducts(keyword: string): Promise<ApiResponse<Product[]>> {
    if (USE_MOCK) {
      await delay()
      const kw = keyword.toLowerCase()
      const results = MockProducts.filter(
        (p: Product) => p.name.includes(kw) || p.craftType.includes(kw)
          || p.tags.some((t: string) => t.includes(kw)) || p.region.includes(kw)
      )
      return { code: 0, message: 'ok', data: results }
    }
    const searchParams: Record<string, string> = {}
    searchParams['keyword'] = keyword
    const resp = await ApiClient.get<PagedData<Product>>('/products/search', searchParams)
    if (resp.code === 0) {
      return { code: 0, message: 'ok', data: resp.data.list }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 发布商品
  static async publishProduct(body: object): Promise<ApiResponse<number>> {
    if (USE_MOCK) {
      await delay(500)
      return { code: 0, message: '发布成功', data: 0 }
    }
    return ApiClient.post<number>('/products', body)
  }
}
