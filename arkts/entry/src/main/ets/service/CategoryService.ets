// 分类服务 — 对接 Spring Boot CategoryController
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'
import { Category } from '../model/Category'

// 后端返回的原始结构（id 等为数字）
interface RawCategory {
  id: number
  name: string
  icon: string
  parentId: number
  sort: number
}

let cachedCategories: Category[] = []

export class CategoryService {

  // 拉取全部分类
  static async fetchCategories(): Promise<ApiResponse<Category[]>> {
    const resp = await ApiClient.get<RawCategory[]>('/categories')
    if (resp.code === 0 && resp.data) {
      const list: Category[] = resp.data.map((c: RawCategory): Category => {
        return {
          id: `${c.id}`,
          name: c.name,
          icon: c.icon || ''
        }
      })
      cachedCategories = list
      return { code: 0, message: 'ok', data: list }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  static getCached(): Category[] {
    return cachedCategories
  }
}
