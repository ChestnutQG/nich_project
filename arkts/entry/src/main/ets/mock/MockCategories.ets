// 非遗分类 Mock 数据
import { Category } from '../model/Category'

export const MockCategories: Category[] = [
  {
    id: 'c001',
    name: '传统美术',
    icon: '🎨',
    children: [
      { id: 'c00101', name: '剪纸', icon: '✂️' },
      { id: 'c00102', name: '刺绣', icon: '🧵' },
      { id: 'c00103', name: '年画', icon: '🖼️' },
      { id: 'c00104', name: '泥塑', icon: '🤲' }
    ]
  },
  {
    id: 'c002',
    name: '传统技艺',
    icon: '🔨',
    children: [
      { id: 'c00201', name: '陶瓷', icon: '🏺' },
      { id: 'c00202', name: '紫砂', icon: '🫖' },
      { id: 'c00203', name: '织锦', icon: '🧶' },
      { id: 'c00204', name: '漆器', icon: '✨' },
      { id: 'c00205', name: '木作', icon: '🪵' }
    ]
  },
  {
    id: 'c003',
    name: '传统医药',
    icon: '🌿'
  },
  {
    id: 'c004',
    name: '民俗',
    icon: '🏮'
  },
  {
    id: 'c005',
    name: '传统戏剧',
    icon: '🎭'
  },
  {
    id: 'c006',
    name: '传统音乐',
    icon: '🎵'
  },
  {
    id: 'c007',
    name: '传统舞蹈',
    icon: '💃'
  },
  {
    id: 'c008',
    name: '曲艺',
    icon: '📖'
  },
  {
    id: 'c009',
    name: '传统体育',
    icon: '🥋'
  },
  {
    id: 'c010',
    name: '民间文学',
    icon: '📜'
  }
]
