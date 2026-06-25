// API 配置 — 集中管理后端连接参数
// IP 地址在 LocalConfig.ets 中配置（不会被提交到 Git）
import { SERVER_IP } from './LocalConfig'

export class ApiConfig {

  // 是否使用 Mock 数据（true=本地Mock, false=连接Spring Boot）
  static readonly USE_MOCK = true

  // Spring Boot 后端地址
  static readonly BASE_URL = `http://${SERVER_IP}:8080`

  // API 前缀
  static readonly API_PREFIX = '/api'
}
