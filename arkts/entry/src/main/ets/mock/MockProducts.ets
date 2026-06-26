// 商品 Mock 数据
import { Product } from '../model/Product'

export const MockProducts: Product[] = [
  {
    id: 'p001',
    name: '苏绣双面绣团扇 · 蝶恋花',
    description: '苏州绣娘纯手工双面绣，一面蝴蝶一面花卉，丝线光泽流转，栩栩如生。扇骨选用湘妃竹，温润如玉。',
    categoryId: 'c001',
    categoryName: '传统美术',
    artisanId: 'a001',
    artisanName: '沈桂芳',
    images: [
      'https://picsum.photos/seed/nh01/750/750',
      'https://picsum.photos/seed/nh02/750/750',
      'https://picsum.photos/seed/nh03/750/750'
    ],
    price: 128000,     // ¥1280.00
    originalPrice: 168000,
    stock: 3,
    sales: 127,
    region: '江苏苏州',
    craftType: '苏绣',
    story: '<p>苏绣，中国四大名绣之首，已有2500余年历史。2006年列入第一批国家级非物质文化遗产名录。</p><p>本件作品出自苏州镇湖沈桂芬女士之手，沈女士8岁随母学艺，至今已从事苏绣四十余载。双面绣是苏绣中难度最高的技法之一，要求绣娘在不打底稿的情况下，凭借对图案的精准把控，实现正反两面图案完全不同、却同样精美的效果。</p>',
    craftProcess: [
      { title: '选料', image: 'https://picsum.photos/seed/nhs01/400/300', description: '选用上等真丝素绉缎为底料，丝线为天然桑蚕丝' },
      { title: '描稿', image: 'https://picsum.photos/seed/nhs02/400/300', description: '在底料上以淡墨勾勒图案轮廓' },
      { title: '劈丝', image: 'https://picsum.photos/seed/nhs03/400/300', description: '将一根丝线劈成1/16甚至1/32的细丝' },
      { title: '绣制', image: 'https://picsum.photos/seed/nhs04/400/300', description: '运用平针、套针、虚实针等数十种针法绣制' }
    ],
    skus: [
      { id: 'sku001', name: '团扇·蝶恋花', price: 128000, stock: 3, image: 'https://picsum.photos/seed/nh01/750/750' }
    ],
    rating: 4.9,
    tags: ['苏绣', '双面绣', '团扇', '国礼级'],
    isCollect: false,
    isSellable: true,
    createTime: 1715673600000
  },
  {
    id: 'p002',
    name: '景德镇青花瓷茶具套装 · 山水清音',
    description: '景德镇非遗传承人手工拉坯，青花手绘山水纹样，一壶四杯一公道，胎薄釉润，发色典雅。',
    categoryId: 'c001',
    categoryName: '传统技艺',
    artisanId: 'a002',
    artisanName: '刘远山',
    images: [
      'https://picsum.photos/seed/nh04/750/750',
      'https://picsum.photos/seed/nh05/750/750'
    ],
    price: 86000,
    originalPrice: 108000,
    stock: 15,
    sales: 356,
    region: '江西景德镇',
    craftType: '青花瓷',
    story: '<p>景德镇手工制瓷技艺，2006年列入国家级非物质文化遗产。青花瓷以钴料在素坯上绘画，罩透明釉后高温一次烧成，洁白的瓷胎上呈现幽蓝纹饰，被誉为"瓷国明珠"。</p>',
    craftProcess: [
      { title: '练泥', image: 'https://picsum.photos/seed/nhc01/400/300', description: '精选高岭土，反复淘洗、沉淀、练制' },
      { title: '拉坯', image: 'https://picsum.photos/seed/nhc02/400/300', description: '在辘轳车上手工拉制成型' },
      { title: '画坯', image: 'https://picsum.photos/seed/nhc03/400/300', description: '以钴料在素坯上绘制山水纹样' },
      { title: '烧窑', image: 'https://picsum.photos/seed/nhc04/400/300', description: '入窑经1300℃高温烧制' }
    ],
    skus: [
      { id: 'sku002', name: '6件套·山水清音', price: 86000, stock: 15, image: 'https://picsum.photos/seed/nh04/750/750' }
    ],
    rating: 4.8,
    tags: ['青花瓷', '茶具', '手工'],
    isCollect: false,
    isSellable: true,
    createTime: 1715846400000
  },
  {
    id: 'p003',
    name: '苗族银饰錾花手镯 · 百鸟朝凤',
    description: '黔东南苗银非遗技艺，纯银手工錾刻百鸟朝凤纹样，繁复精美，承载苗族千年银饰文化。',
    categoryId: 'c003',
    categoryName: '传统技艺',
    artisanId: 'a003',
    artisanName: '杨阿妹',
    images: [
      'https://picsum.photos/seed/nh07/750/750',
      'https://picsum.photos/seed/nh08/750/750'
    ],
    price: 56000,
    originalPrice: 68000,
    stock: 7,
    sales: 89,
    region: '贵州黔东南',
    craftType: '苗族银饰',
    story: '<p>苗族银饰锻制技艺，2006年列入国家级非物质文化遗产。苗族人认为银饰可以驱邪避灾、祈福纳祥，每一件银饰都是苗族文化的活态传承。</p>',
    craftProcess: [
      { title: '熔银', image: 'https://picsum.photos/seed/nhm01/400/300', description: '将银料高温熔化，铸成银条' },
      { title: '锻打', image: 'https://picsum.photos/seed/nhm02/400/300', description: '反复锻打银条成型' },
      { title: '錾花', image: 'https://picsum.photos/seed/nhm03/400/300', description: '以錾子手工刻出百鸟朝凤纹样' },
      { title: '抛光', image: 'https://picsum.photos/seed/nhm04/400/300', description: '精细打磨，呈现银饰特有的光泽' }
    ],
    skus: [
      { id: 'sku003', name: '百鸟朝凤·标准款', price: 56000, stock: 7, image: 'https://picsum.photos/seed/nh07/750/750' }
    ],
    rating: 4.7,
    tags: ['苗银', '手镯', '錾刻'],
    isCollect: true,
    isSellable: true,
    createTime: 1716364800000
  },
  {
    id: 'p004',
    name: '宜兴紫砂壶 · 仿古如意',
    description: '宜兴紫砂非遗传承人全手工制作，原矿紫泥，壶身饱满圆润，出水流畅，养壶佳品。',
    categoryId: 'c002',
    categoryName: '传统技艺',
    artisanId: 'a004',
    artisanName: '顾景明',
    images: [
      'https://picsum.photos/seed/nh10/750/750',
      'https://picsum.photos/seed/nh11/750/750'
    ],
    price: 198000,
    originalPrice: 238000,
    stock: 2,
    sales: 64,
    region: '江苏宜兴',
    craftType: '紫砂陶',
    story: '<p>宜兴紫砂陶制作技艺，2006年列入国家级非物质文化遗产。紫砂壶以其独特的双气孔结构，能充分激发茶香茶韵，素有"世间茶具堪为首"的美誉。</p>',
    craftProcess: [
      { title: '选泥', image: 'https://picsum.photos/seed/nhz01/400/300', description: '精选宜兴黄龙山原矿紫泥' },
      { title: '捶泥', image: 'https://picsum.photos/seed/nhz02/400/300', description: '反复捶打排除泥料中的空气' },
      { title: '拍身筒', image: 'https://picsum.photos/seed/nhz03/400/300', description: '以搭子拍打出壶身造型' },
      { title: '明针', image: 'https://picsum.photos/seed/nhz04/400/300', description: '用牛角明针反复刮压壶面使其光滑细腻' }
    ],
    skus: [
      { id: 'sku004', name: '仿古如意·中品', price: 198000, stock: 2, image: 'https://picsum.photos/seed/nh10/750/750' }
    ],
    rating: 5.0,
    tags: ['紫砂', '茶壶', '全手工'],
    isCollect: false,
    isSellable: true,
    createTime: 1716537600000
  },
  {
    id: 'p005',
    name: '四川蜀锦手提包 · 芙蓉花开',
    description: '成都蜀锦织造技艺，天然桑蚕丝织就芙蓉花纹样，手工缝制成手拿包，传统工艺与现代设计的完美融合。',
    categoryId: 'c001',
    categoryName: '传统美术',
    artisanId: 'a005',
    artisanName: '杨德全',
    images: [
      'https://picsum.photos/seed/nh13/750/750',
      'https://picsum.photos/seed/nh14/750/750'
    ],
    price: 36800,
    originalPrice: 45800,
    stock: 12,
    sales: 203,
    region: '四川成都',
    craftType: '蜀锦',
    story: '<p>蜀锦织造技艺，2006年列入国家级非物质文化遗产。蜀锦与云锦、宋锦、壮锦并称中国四大名锦，其织造工艺极为复杂，一天仅能织出几厘米。</p>',
    craftProcess: [
      { title: '设计纹样', image: 'https://picsum.photos/seed/nhj01/400/300', description: '设计芙蓉花纹样意匠图' },
      { title: '挑花结本', image: 'https://picsum.photos/seed/nhj02/400/300', description: '将纹样转换为织机可识别的花本' },
      { title: '织造', image: 'https://picsum.photos/seed/nhj03/400/300', description: '在传统花楼织机上手工织造' },
      { title: '缝制', image: 'https://picsum.photos/seed/nhj04/400/300', description: '老匠人手工裁剪缝制成包' }
    ],
    skus: [
      { id: 'sku005', name: '芙蓉花开·标准款', price: 36800, stock: 12, image: 'https://picsum.photos/seed/nh13/750/750' }
    ],
    rating: 4.6,
    tags: ['蜀锦', '手提包', '丝绸'],
    isCollect: false,
    isSellable: true,
    createTime: 1716883200000
  },
  {
    id: 'p006',
    name: '徽州歙砚 · 云龙纹',
    description: '歙砚制作技艺非遗传承人亲制，精选老坑金星砚石，雕云龙纹，下发墨极佳，文房雅器。',
    categoryId: 'c002',
    categoryName: '传统技艺',
    artisanId: 'a006',
    artisanName: '程振华',
    images: [
      'https://picsum.photos/seed/nh16/750/750',
      'https://picsum.photos/seed/nh17/750/750'
    ],
    price: 158000,
    originalPrice: 188000,
    stock: 1,
    sales: 38,
    region: '安徽黄山',
    craftType: '歙砚',
    story: '<p>歙砚制作技艺，2008年列入国家级非物质文化遗产。歙砚为中国四大名砚之一，始于唐代，以石质坚韧、温润如玉、发墨如油著称。</p>',
    craftProcess: [
      { title: '选石', image: 'https://picsum.photos/seed/nhy01/400/300', description: '砚山老坑采石，精选金星纹理砚材' },
      { title: '设计', image: 'https://picsum.photos/seed/nhy02/400/300', description: '根据石形石纹设计云龙构图' },
      { title: '雕刻', image: 'https://picsum.photos/seed/nhy03/400/300', description: '以刀代笔，精细雕刻云龙纹样' },
      { title: '打磨', image: 'https://picsum.photos/seed/nhy04/400/300', description: '反复打磨至温润如玉的手感' }
    ],
    skus: [
      { id: 'sku006', name: '云龙纹·金星坑', price: 158000, stock: 1, image: 'https://picsum.photos/seed/nh16/750/750' }
    ],
    rating: 5.0,
    tags: ['歙砚', '文房', '孤品'],
    isCollect: true,
    isSellable: true,
    createTime: 1717056000000
  }
]

// 首页推荐商品（取前4个）
export function getRecommendProducts(): Product[] {
  return MockProducts.slice(0, 4)
}

// 按分类筛选商品
export function getProductsByCategory(categoryId: string): Product[] {
  return MockProducts.filter(p => p.categoryId === categoryId)
}

// 商品详情
export function getProductById(id: string): Product | undefined {
  return MockProducts.find(p => p.id === id)
}
