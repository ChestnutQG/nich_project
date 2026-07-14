// API 配置 — 集中管理后端连接参数

export class ApiConfig {

  // 是否使用 Mock 数据（true=本地Mock, false=连接Spring Boot）
  static readonly USE_MOCK = false

  // 默认公网服务器。该地址随源码提交，克隆项目后无需额外配置。
  static readonly SERVER_HOST = '111.228.8.229'
  static readonly BASE_URL = `http://${ApiConfig.SERVER_HOST}`

  // API 前缀
  static readonly API_PREFIX = '/api'
}
