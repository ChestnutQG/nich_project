// 匠人 Mock 数据
import { Artisan } from '../model/Artisan'

export const MockArtisans: Artisan[] = [
  {
    id: 'a001',
    name: '沈桂芳',
    avatar: 'https://picsum.photos/seed/art01/200/200',
    title: '国家级非遗传承人',
    level: 3,
    province: '江苏',
    city: '苏州',
    craftType: '苏绣',
    intro: '沈桂芳，1958年生于苏州镇湖刺绣世家，8岁随母学绣，16岁独立完成大幅作品。从事苏绣四十余年，尤擅双面绣与仿真绣，作品多次作为国礼赠送外宾。现为国家级非物质文化遗产项目（苏绣）代表性传承人。',
    certificateImages: ['https://picsum.photos/seed/cert01/400/300'],
    worksCount: 156,
    followersCount: 3280,
    isFollowed: false
  },
  {
    id: 'a002',
    name: '刘远山',
    avatar: 'https://picsum.photos/seed/art02/200/200',
    title: '省级非遗传承人',
    level: 2,
    province: '江西',
    city: '景德镇',
    craftType: '青花瓷',
    intro: '刘远山，1970年生于景德镇陶瓷世家，13岁入厂学艺，师从中国工艺美术大师王锡良。擅长青花山水，笔法洒脱大气，青花发色层次丰富，被誉为"当代青花山水第一人"。',
    certificateImages: ['https://picsum.photos/seed/cert02/400/300'],
    worksCount: 89,
    followersCount: 1580,
    isFollowed: true
  },
  {
    id: 'a003',
    name: '杨阿妹',
    avatar: 'https://picsum.photos/seed/art03/200/200',
    title: '省级非遗传承人',
    level: 2,
    province: '贵州',
    city: '黔东南',
    craftType: '苗族银饰',
    intro: '杨阿妹，1975年生于贵州黔东南雷山县西江千户苗寨，自小跟随祖母和母亲学习苗族银饰锻制技艺。坚持用传统工具纯手工制作，作品远销海外，是苗银文化的重要传播者。',
    certificateImages: ['https://picsum.photos/seed/cert03/400/300'],
    worksCount: 234,
    followersCount: 2100,
    isFollowed: false
  },
  {
    id: 'a004',
    name: '顾景明',
    avatar: 'https://picsum.photos/seed/art04/200/200',
    title: '国家级非遗传承人',
    level: 3,
    province: '江苏',
    city: '宜兴',
    craftType: '紫砂陶',
    intro: '顾景明，1945年生于宜兴丁蜀镇，15岁进紫砂工艺厂学艺，从事紫砂壶制作近六十载。作品以传统光素器见长，造型古朴大方，线条流畅自然，多次获国家级工艺美术金奖。',
    certificateImages: ['https://picsum.photos/seed/cert04/400/300'],
    worksCount: 412,
    followersCount: 5860,
    isFollowed: false
  },
  {
    id: 'a005',
    name: '杨德全',
    avatar: 'https://picsum.photos/seed/art05/200/200',
    title: '国家级非遗传承人',
    level: 3,
    province: '四川',
    city: '成都',
    craftType: '蜀锦',
    intro: '杨德全，1955年出生于成都蜀锦世家，蜀锦织造技艺国家级非遗传承人。五十余年坚守织机旁，将传统蜀锦与现代生活结合，让千年蜀锦走进寻常百姓家。',
    certificateImages: ['https://picsum.photos/seed/cert05/400/300'],
    worksCount: 78,
    followersCount: 920,
    isFollowed: false
  },
  {
    id: 'a006',
    name: '程振华',
    avatar: 'https://picsum.photos/seed/art06/200/200',
    title: '省级非遗传承人',
    level: 2,
    province: '安徽',
    city: '黄山',
    craftType: '歙砚',
    intro: '程振华，1968年生于歙县砚雕世家，16岁随父学艺，专攻歙砚雕刻三十余年。作品因石制宜、因材施艺，刀法细腻，曾获中国工艺美术"百花奖"金奖。',
    certificateImages: ['https://picsum.photos/seed/cert06/400/300'],
    worksCount: 56,
    followersCount: 430,
    isFollowed: false
  }
]

// 热门推荐匠人（按关注数排序取前4）
export function getHotArtisans(): Artisan[] {
  return [...MockArtisans].sort((a, b) => b.followersCount - a.followersCount).slice(0, 4)
}

// 匠人详情
export function getArtisanById(id: string): Artisan | undefined {
  return MockArtisans.find(a => a.id === id)
}
