// 通用工具函数

export class Utils {
  // 分转元，保留两位小数
  static fenToYuan(fen: number): string {
    return (fen / 100).toFixed(2)
  }

  // 价格展示（分 -> ¥xx.xx）
  static formatPrice(fen: number): string {
    return `¥${Utils.fenToYuan(fen)}`
  }

  // 数字超过999显示为 x.xk
  static formatCount(num: number): string {
    if (num >= 10000) {
      return `${(num / 10000).toFixed(1)}万`
    }
    if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}k`
    }
    return `${num}`
  }

  // 时间戳转可读日期
  static formatDate(timestamp: number): string {
    const d = new Date(timestamp)
    const y = d.getFullYear()
    const m = `${d.getMonth() + 1}`.padStart(2, '0')
    const day = `${d.getDate()}`.padStart(2, '0')
    const h = `${d.getHours()}`.padStart(2, '0')
    const min = `${d.getMinutes()}`.padStart(2, '0')
    return `${y}-${m}-${day} ${h}:${min}`
  }

  // 生成唯一 ID（简单版本，正式环境应使用服务端 ID）
  static generateId(): string {
    return `${Date.now()}_${Math.random().toString(36).slice(2, 9)}`
  }
}
