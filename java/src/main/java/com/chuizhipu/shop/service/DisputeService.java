package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.*;
import com.chuizhipu.shop.mapper.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class DisputeService {

    private final DisputeMapper disputeMapper;
    private final JuryInvitationMapper invitationMapper;
    private final JuryVoteMapper voteMapper;
    private final OrderMapper orderMapper;
    private final UserMapper userMapper;

    public DisputeService(DisputeMapper disputeMapper, JuryInvitationMapper invitationMapper,
                          JuryVoteMapper voteMapper, OrderMapper orderMapper,
                          UserMapper userMapper) {
        this.disputeMapper = disputeMapper;
        this.invitationMapper = invitationMapper;
        this.voteMapper = voteMapper;
        this.orderMapper = orderMapper;
        this.userMapper = userMapper;
    }

    /** 创建纠纷 */
    @Transactional
    public Long createDispute(Long orderId, Long initiatorId, String reason, String evidenceUrls) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) throw new IllegalArgumentException("订单不存在");
        if (order.getStatus() != 2 && order.getStatus() != 3)
            throw new IllegalArgumentException("仅已收货/已完成的订单可申请维权");
        if (disputeMapper.existsByOrderId(orderId))
            throw new IllegalArgumentException("该订单已有维权在处理中");

        Dispute dispute = new Dispute();
        dispute.setOrderId(orderId);
        dispute.setInitiatorId(initiatorId);
        dispute.setRespondentId(order.getUserId().equals(initiatorId) ?
                getSellerId(orderId) : order.getUserId());
        dispute.setReason(reason);
        dispute.setEvidenceUrls(evidenceUrls);
        dispute.setStatus("negotiating");
        disputeMapper.insert(dispute);

        // 订单状态改为退款中
        orderMapper.updateStatus(orderId, 4);
        return dispute.getId();
    }

    /** 申请陪审团 */
    @Transactional
    public void requestJury(Long disputeId, Long requesterId) {
        Dispute dispute = disputeMapper.selectById(disputeId);
        if (dispute == null) throw new IllegalArgumentException("纠纷不存在");
        if (!"negotiating".equals(dispute.getStatus()))
            throw new IllegalArgumentException("当前状态不可申请陪审团");

        // 随机邀请 15-20 名合格陪审员
        List<Long> excludeIds = new ArrayList<>();
        excludeIds.add(dispute.getInitiatorId());
        excludeIds.add(dispute.getRespondentId());
        List<Long> jurors = invitationMapper.selectEligibleJurors(excludeIds);
        if (jurors.size() < 5) throw new IllegalArgumentException("合格陪审员不足，无法组建陪审团");

        int count = Math.min(jurors.size(), 15 + new Random().nextInt(6));
        Collections.shuffle(jurors);
        List<Long> selected = jurors.subList(0, count);

        List<JuryInvitation> invitations = new ArrayList<>();
        for (Long jurorId : selected) {
            JuryInvitation inv = new JuryInvitation();
            inv.setDisputeId(disputeId);
            inv.setUserId(jurorId);
            inv.setStatus("pending");
            invitations.add(inv);
        }
        invitationMapper.batchInsert(invitations);

        disputeMapper.updateStatus(disputeId, "voting");
    }

    /** 投票 */
    @Transactional
    public void vote(Long disputeId, Long voterId, String voteSide) {
        Dispute dispute = disputeMapper.selectById(disputeId);
        if (dispute == null) throw new IllegalArgumentException("纠纷不存在");
        if (!"voting".equals(dispute.getStatus()))
            throw new IllegalArgumentException("当前不在投票阶段");

        if (!invitationMapper.existsByDisputeAndUser(disputeId, voterId))
            throw new IllegalArgumentException("您未被邀请参与陪审");
        if (voteMapper.existsByDisputeAndVoter(disputeId, voterId))
            throw new IllegalArgumentException("您已投过票");

        JuryVote vote = new JuryVote();
        vote.setDisputeId(disputeId);
        vote.setVoterId(voterId);
        vote.setVoteSide(voteSide);
        voteMapper.insert(vote);

        // 更新邀请状态
        List<JuryInvitation> invitations = invitationMapper.selectByDisputeId(disputeId);
        for (JuryInvitation inv : invitations) {
            if (inv.getUserId().equals(voterId)) {
                invitationMapper.updateStatus(inv.getId(), "voted");
            }
        }

        // 检查投票是否足够
        int total = voteMapper.countByDisputeId(disputeId);
        if (total >= 10) {
            resolveDispute(disputeId);
        }
    }

    /** 裁决纠纷 */
    public void resolveDispute(Long disputeId) {
        Dispute dispute = disputeMapper.selectById(disputeId);
        if (dispute == null || "resolved".equals(dispute.getStatus())) return;

        int buyerVotes = voteMapper.countByDisputeAndSide(disputeId, "buyer");
        int sellerVotes = voteMapper.countByDisputeAndSide(disputeId, "seller");
        int total = buyerVotes + sellerVotes;

        if (total == 0) return;
        double buyerRate = (double) buyerVotes / total;
        String result = buyerRate >= 0.66 ? "buyer_win" : "seller_win";

        disputeMapper.updateResult(disputeId, result, buyerVotes, sellerVotes);

        // 买家胜 → 订单退款中变为取消
        if ("buyer_win".equals(result)) {
            orderMapper.updateStatus(dispute.getOrderId(), 5); // 已取消
        } else {
            orderMapper.updateStatus(dispute.getOrderId(), 3); // 回到已完成
        }
    }

    /** 自动处理超时纠纷（定时任务） */
    @Transactional
    public void resolveOverdueDisputes() {
        List<Dispute> votingDisputes = disputeMapper.selectByStatus("voting");
        for (Dispute d : votingDisputes) {
            if (d.getCreatedAt() != null &&
                    d.getCreatedAt().plusHours(24).isBefore(java.time.LocalDateTime.now())) {
                // 24h 后追加 3 个陪审员
                List<Long> excludeIds = new ArrayList<>();
                excludeIds.add(d.getInitiatorId());
                excludeIds.add(d.getRespondentId());
                List<JuryInvitation> existing = invitationMapper.selectByDisputeId(d.getId());
                for (JuryInvitation inv : existing) excludeIds.add(inv.getUserId());

                List<Long> extra = invitationMapper.selectEligibleJurors(excludeIds);
                if (!extra.isEmpty()) {
                    int extraCount = Math.min(extra.size(), 3);
                    List<JuryInvitation> newInvs = new ArrayList<>();
                    for (int i = 0; i < extraCount; i++) {
                        JuryInvitation inv = new JuryInvitation();
                        inv.setDisputeId(d.getId());
                        inv.setUserId(extra.get(i));
                        inv.setStatus("pending");
                        newInvs.add(inv);
                    }
                    invitationMapper.batchInsert(newInvs);
                }
                // 强制裁决
                resolveDispute(d.getId());
            }
        }
    }

    public Dispute getById(Long id) {
        return disputeMapper.selectById(id);
    }

    public List<Dispute> getMyDisputes(Long userId) {
        return disputeMapper.selectByUser(userId);
    }

    public Map<String, Object> voteStats(Long disputeId) {
        int buyerVotes = voteMapper.countByDisputeAndSide(disputeId, "buyer");
        int sellerVotes = voteMapper.countByDisputeAndSide(disputeId, "seller");
        int total = buyerVotes + sellerVotes;
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("totalVotes", total);
        stats.put("buyerVotes", buyerVotes);
        stats.put("sellerVotes", sellerVotes);
        stats.put("buyerRate", total > 0 ? Math.round(buyerVotes * 100.0 / total) : 0);
        return stats;
    }

    public List<JuryInvitation> getMyInvitations(Long userId) {
        return invitationMapper.selectByUserId(userId);
    }

    private Long getSellerId(Long orderId) {
        // 从订单项商品中查 seller：通过 artisan_id 或 product 关联
        // 简化处理：订单关联 buyer，从 product 查 artisan
        return null; // 实际从订单中取 respondent
    }
}
