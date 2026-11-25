// 匠人/传承人数据模型

export interface Artisan {
  id: string
  userId: string       // 对应用户登录ID，用于聊天
  name: string
  avatar: string
  title: string          // 头衔，如"国家级非遗传承人"
  level: number          // 认证等级 1-3（县级/省级/国家级）
  province: string
  city: string
  craftType: string      // 擅长技艺
  intro: string
  certificateImages: string[]
  worksCount: number
  followersCount: number
  isFollowed: boolean
}
