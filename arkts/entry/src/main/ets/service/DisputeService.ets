// 小法庭维权服务
import { ApiClient } from './ApiClient'
import { ApiResponse } from '../model/ApiResponse'
import { Dispute, JuryInvitation, VoteStats } from '../model/Dispute'

interface CreateReq {
  orderId: string
  reason: string
  evidenceUrls: string
}

interface VoteReq {
  disputeId: string
  voteSide: string
}

interface EmptyReq {}

export class DisputeService {

  static async create(orderId: string, reason: string, evidenceUrls: string): Promise<ApiResponse<number>> {
    const body: CreateReq = { orderId, reason, evidenceUrls }
    return await ApiClient.post<number>('/disputes', body)
  }

  static async requestJury(disputeId: string): Promise<ApiResponse<null>> {
    const empty: EmptyReq = {}
    return await ApiClient.put<null>(`/disputes/${disputeId}/request-jury`, empty)
  }

  static async getDetail(disputeId: string): Promise<ApiResponse<Dispute>> {
    return await ApiClient.get<Dispute>(`/disputes/${disputeId}`)
  }

  static async getMyDisputes(): Promise<ApiResponse<Dispute[]>> {
    return await ApiClient.get<Dispute[]>('/disputes/mine')
  }

  static async getVoteStats(disputeId: string): Promise<ApiResponse<VoteStats>> {
    return await ApiClient.get<VoteStats>(`/disputes/${disputeId}/vote-stats`)
  }

  static async getMyInvitations(): Promise<ApiResponse<JuryInvitation[]>> {
    return await ApiClient.get<JuryInvitation[]>('/jury/invitations/mine')
  }

  static async vote(disputeId: string, voteSide: string): Promise<ApiResponse<null>> {
    const body: VoteReq = { disputeId, voteSide }
    return await ApiClient.post<null>('/jury/votes', body)
  }
}
