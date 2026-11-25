// 纠纷 / 小法庭数据模型

export interface Dispute {
  id: string
  orderId: string
  initiatorId: string
  respondentId: string
  reason: string
  evidenceUrls: string           // JSON string array
  status: string                 // negotiating | voting | resolved
  result?: string                // buyer_win | seller_win
  buyerVotes: number
  sellerVotes: number
  createdAt: string
  updatedAt: string
  // 关联字段
  orderNo: string
  productId: string
  productName: string
  initiatorName: string
  respondentName: string
}

export interface JuryInvitation {
  id: string
  disputeId: string
  userId: string
  status: string                 // pending | voted
  inviteTime: string
  voteTime?: string
  // 关联
  disputeReason: string
  userName: string
}

export interface VoteStats {
  totalVotes: number
  buyerVotes: number
  sellerVotes: number
  buyerRate: number
}

export function getDisputeStatusText(status: string): string {
  switch (status) {
    case 'negotiating': return '协商中'
    case 'voting': return '投票中'
    case 'resolved': return '已裁决'
    default: return status
  }
}

export function getDisputeResultText(result: string): string {
  switch (result) {
    case 'buyer_win': return '买家胜诉'
    case 'seller_win': return '卖家胜诉'
    default: return result
  }
}
