// 非遗分类数据模型

export interface Category {
  id: string
  name: string
  icon: string         // 图标资源路径或文字图标
  children?: Category[]
}
