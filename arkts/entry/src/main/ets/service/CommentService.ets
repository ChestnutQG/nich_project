// 评论服务 — 对接 Spring Boot CommentController
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'

// 与商品详情页 Comment 接口字段一致
export interface CommentItem {
  id: string
  userName: string
  avatar: string
  content: string
  time: string
}

interface CommentReq {
  content: string
}

export class CommentService {

  // 某商品的评论列表
  static async fetchComments(productId: string): Promise<ApiResponse<CommentItem[]>> {
    const resp = await ApiClient.get<CommentItem[]>(`/products/${productId}/comments`)
    if (resp.code === 0 && resp.data) {
      return { code: 0, message: 'ok', data: resp.data }
    }
    return { code: resp.code, message: resp.message, data: [] }
  }

  // 发表评论
  static async addComment(productId: string, content: string): Promise<ApiResponse<number>> {
    const body: CommentReq = { content }
    return ApiClient.post<number>(`/products/${productId}/comments`, body)
  }
}
