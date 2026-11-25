// 统一 API 响应结构

export interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

export interface PagedData<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
}
