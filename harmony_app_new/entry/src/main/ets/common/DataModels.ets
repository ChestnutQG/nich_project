// ==================== 通用数据结构 ====================
// API通用响应
export interface ApiResp {
  code: number;
  message: string;
  data: Object | null;
}

// 分页结果——泛型T为列表元素类型
export class PageResult<T> {
  records: T[] = [];
  total: number = 0;
  page: number = 0;
  size: number = 0;
}

// ==================== 内容与商品 ====================
// 内容帖子（非遗作品分享）
export class ContentItem {
  id: number = 0;
  userId: number = 0;
  title: string = '';
  description: string = '';
  type: string = '';
  mediaUrls: string = '';
  tags: string = '';
  status: string = '';
  rejectReason: string = '';
  likeCount: number = 0;
  viewCount: number = 0;
  isSellable: boolean = false;
  createdAt: string = '';
  authorName: string = '';
  authorAvatar: string = '';
  products: ProductItem[] = [];
}

// 关联商品
export class ProductItem {
  id: number = 0;
  contentId: number = 0;
  sellerId: number = 0;
  name: string = '';
  price: number = 0;
  stock: number = 0;
  description: string = '';
  images: string = '';
  status: string = '';
}

// ==================== 订单与纠纷 ====================
// 订单
export class OrderItem {
  id: number = 0;
  buyerId: number = 0;
  sellerId: number = 0;
  productId: number = 0;
  amount: number = 0;
  status: string = '';
  afterSaleStatus: string = '';
  logisticsNo: string = '';
  returnLogisticsNo: string = '';
  createdAt: string = '';
}

// 纠纷/小法庭案件
export class DisputeItem {
  id: number = 0;
  orderId: number = 0;
  initiatorId: number = 0;
  respondentId: number = 0;
  reason: string = '';
  evidenceUrls: string = '';
  status: string = '';
  result: string = '';
  buyerSupportRate: number = 0;
  createdAt: string = '';
  updatedAt: string = '';
}

// 陪审邀请
export class JuryInvitationItem {
  id: number = 0;
  disputeId: number = 0;
  userId: number = 0;
  status: string = '';
  inviteTime: string = '';
  voteTime: string = '';
}

// ==================== 用户 ====================
// 用户信息
export class UserInfo {
  id: number = 0;
  username: string = '';
  phone: string = '';
  avatarUrl: string = '';
  role: string = '';          // 角色：user / admin
  creditScore: number = 0;    // 信用分
}

// 登录/注册返回结果
export class LoginResult {
  token: string = '';
  userId: number = 0;
  username: string = '';
  role: string = '';
  avatarUrl: string = '';
}
