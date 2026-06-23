// 应用常量

export class Constants {
  // 应用信息
  static readonly APP_NAME = '锤子铺'
  static readonly APP_VERSION = '1.0.0'

  // 页面路由
  static readonly PAGE_INDEX = 'pages/Index'
  static readonly PAGE_SEARCH = 'pages/Search'
  static readonly PAGE_CATEGORY = 'pages/Category'
  static readonly PAGE_PRODUCT_LIST = 'pages/ProductList'
  static readonly PAGE_PRODUCT_DETAIL = 'pages/ProductDetail'
  static readonly PAGE_CART = 'pages/Cart'
  static readonly PAGE_ORDER_CONFIRM = 'pages/OrderConfirm'
  static readonly PAGE_ORDER_LIST = 'pages/OrderList'
  static readonly PAGE_ORDER_DETAIL = 'pages/OrderDetail'
  static readonly PAGE_LOGIN = 'pages/Login'
  static readonly PAGE_PROFILE = 'pages/Profile'
  static readonly PAGE_ADDRESS_LIST = 'pages/AddressList'
  static readonly PAGE_ARTISAN_LIST = 'pages/ArtisanList'
  static readonly PAGE_ARTISAN_DETAIL = 'pages/ArtisanDetail'
  static readonly PAGE_WIKI_INDEX = 'pages/WikiIndex'
  static readonly PAGE_WIKI_DETAIL = 'pages/WikiDetail'
  static readonly PAGE_PRODUCT_PUBLISH = 'pages/ProductPublish'
  static readonly PAGE_PROFILE_EDIT = 'pages/ProfileEdit'

  // 非遗传承认证等级
  static readonly ARTISAN_LEVEL_TEXT: Record<number, string> = {
    1: '县级非遗传承人',
    2: '省级非遗传承人',
    3: '国家级非遗传承人'
  }

  // 非遗十大类别
  static readonly HERITAGE_CATEGORIES = [
    '传统技艺', '传统美术', '传统医药', '民俗',
    '传统戏剧', '传统音乐', '传统舞蹈', '曲艺',
    '传统体育', '民间文学'
  ]
}
