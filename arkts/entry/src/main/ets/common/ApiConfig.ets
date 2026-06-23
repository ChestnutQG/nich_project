// API 配置 — 集中管理后端连接参数
// 切换 Mock / 真实后端时只需改这里

export class ApiConfig {

  // 是否使用 Mock 数据（true=本地Mock, false=连接Spring Boot）
  static readonly USE_MOCK = true

  // Spring Boot 后端地址
  // 模拟器用: http://10.0.2.2:8080
  // 真机调试用: http://电脑局域网IP:8080
  static readonly BASE_URL = 'http://10.142.230.64:8080'

  // API 前缀
  static readonly API_PREFIX = '/api'
}
