package com.nonheritage.demo.service;

import com.nonheritage.demo.dto.DisputeRequest;
import com.nonheritage.demo.dto.VoteRequest;
import com.nonheritage.demo.entity.*;
import com.nonheritage.demo.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;

/** 纠纷服务：发起纠纷、陪审团机制、投票统计、超时自动裁决 */
@Service
public class DisputeService {
    private final DisputeRepository disputeRepository;
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final JuryInvitationRepository invitationRepository;
    private final JuryVoteRepository voteRepository;

    public DisputeService(DisputeRepository disputeRepository, OrderRepository orderRepository,
                          UserRepository userRepository, JuryInvitationRepository invitationRepository,
                          JuryVoteRepository voteRepository) {
        this.disputeRepository = disputeRepository;
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
        this.invitationRepository = invitationRepository;
        this.voteRepository = voteRepository;
    }

    /** 买家发起纠纷，订单售后状态→disputing @param userId 发起人ID @param req 纠纷请求 @return 创建的纠纷 */
    @Transactional
    public Dispute create(Long userId, DisputeRequest req) {
        Order order = orderRepository.findById(req.getOrderId())
                .orElseThrow(() -> new IllegalArgumentException("订单不存在"));
        if (!order.getBuyerId().equals(userId))
            throw new IllegalArgumentException("只有买家可以发起纠纷");
        if (!"received".equals(order.getStatus()))
            throw new IllegalArgumentException("订单未确认收货，无法发起纠纷");
        if (!"none".equals(order.getAfterSaleStatus()))
            throw new IllegalArgumentException("已存在售后记录");

        order.setAfterSaleStatus("disputing");
        orderRepository.save(order);

        Dispute d = new Dispute();
        d.setOrderId(req.getOrderId());
        d.setInitiatorId(userId);
        d.setRespondentId(order.getSellerId());
        d.setReason(req.getReason());
        d.setEvidenceUrls(req.getEvidenceUrls());
        d.setStatus("negotiating");
        return disputeRepository.save(d);
    }

    /** 查询纠纷详情 @param id 纠纷ID @return 纠纷 */
    public Dispute getById(Long id) {
        return disputeRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("纠纷不存在"));
    }

    /** 申请陪审团介入，随机邀请10~20位陪审员 @param disputeId 纠纷ID @param userId 申请者ID @return 更新后的纠纷 */
    @Transactional
    public Dispute requestJury(Long disputeId, Long userId) {
        Dispute d = getById(disputeId);
        if (!d.getInitiatorId().equals(userId) && !d.getRespondentId().equals(userId))
            throw new IllegalArgumentException("无权操作");
        if (!"negotiating".equals(d.getStatus()))
            throw new IllegalArgumentException("当前状态不可申请陪审");

        d.setStatus("pending_jury");
        d.setUpdatedAt(LocalDateTime.now());
        disputeRepository.save(d);

        inviteJurors(disputeId, 10, 20);
        d.setStatus("voting");
        d.setUpdatedAt(LocalDateTime.now());
        return disputeRepository.save(d);
    }

    /** 随机邀请陪审员，排除纠纷双方和已邀请者 @param disputeId 纠纷ID @param min 最少人数 @param max 最多人数 */
    private void inviteJurors(Long disputeId, int min, int max) {
        Dispute d = getById(disputeId);
        List<Long> exclude = new ArrayList<>();
        exclude.add(d.getInitiatorId());
        exclude.add(d.getRespondentId());

        List<JuryInvitation> existing = invitationRepository.findByDisputeId(disputeId);
        for (JuryInvitation inv : existing) exclude.add(inv.getUserId());

        List<User> pool = userRepository.findEligibleJurors(exclude);
        Collections.shuffle(pool);
        int count = Math.min(pool.size(), min + new Random().nextInt(max - min + 1));

        for (int i = 0; i < count; i++) {
            JuryInvitation inv = new JuryInvitation();
            inv.setDisputeId(disputeId);
            inv.setUserId(pool.get(i).getId());
            inv.setStatus("pending");
            inv.setInviteTime(LocalDateTime.now());
            invitationRepository.save(inv);
        }
    }

    /** 我的陪审邀请列表 @param userId 用户ID @return 邀请列表 */
    public List<JuryInvitation> myInvitations(Long userId) {
        return invitationRepository.findByUserIdOrderByInviteTimeDesc(userId);
    }

    /** 陪审员投票，只能投一次 @param userId 投票人ID @param req 投票请求 */
    @Transactional
    public void vote(Long userId, VoteRequest req) {
        Dispute d = getById(req.getDisputeId());
        if (!"voting".equals(d.getStatus()))
            throw new IllegalArgumentException("当前不可投票");

        JuryInvitation inv = invitationRepository.findByDisputeId(req.getDisputeId()).stream()
                .filter(i -> i.getUserId().equals(userId) && "pending".equals(i.getStatus()))
                .findFirst().orElseThrow(() -> new IllegalArgumentException("无待投票的陪审邀请"));

        if (voteRepository.existsByDisputeIdAndVoterId(req.getDisputeId(), userId))
            throw new IllegalArgumentException("已投票");

        JuryVote vote = new JuryVote();
        vote.setDisputeId(req.getDisputeId());
        vote.setVoterId(userId);
        vote.setVoteSide(req.getVoteSide());
        voteRepository.save(vote);

        inv.setStatus("voted");
        inv.setVoteTime(LocalDateTime.now());
        invitationRepository.save(inv);
    }

    /** 投票统计 @param disputeId 纠纷ID @return 总票数、双方票数、支持率 */
    public Map<String, Object> voteStats(Long disputeId) {
        long total = voteRepository.countByDisputeId(disputeId);
        long buyerVotes = voteRepository.countByDisputeIdAndVoteSide(disputeId, "buyer");
        long sellerVotes = voteRepository.countByDisputeIdAndVoteSide(disputeId, "seller");

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalVotes", total);
        stats.put("buyerVotes", buyerVotes);
        stats.put("sellerVotes", sellerVotes);
        if (total > 0) {
            stats.put("buyerRate", BigDecimal.valueOf(buyerVotes * 100.0 / total).setScale(2, RoundingMode.HALF_UP));
        } else {
            stats.put("buyerRate", BigDecimal.ZERO);
        }
        return stats;
    }

    /** 我相关的纠纷（发起或被告） @param userId 用户ID @return 纠纷列表 */
    public List<Dispute> myDisputes(Long userId) {
        return disputeRepository.findByInitiatorIdOrRespondentIdOrderByCreatedAtDesc(userId, userId);
    }

    /** 定时任务调用：超24小时自动裁决（>=66%支持率→买家胜，否则卖家胜） */
    // Called by scheduler
    @Transactional
    public void resolveOverdueDisputes() {
        List<Dispute> votingDisputes = disputeRepository.findByStatus("voting");
        LocalDateTime cutoff = LocalDateTime.now().minusHours(24);

        for (Dispute d : votingDisputes) {
            if (d.getUpdatedAt().isAfter(cutoff)) continue;

            long totalVotes = voteRepository.countByDisputeId(d.getId());
            if (totalVotes < 10) {
                inviteJurors(d.getId(), 3, 3);
                d.setUpdatedAt(LocalDateTime.now().plusHours(6));
                disputeRepository.save(d);
                continue;
            }

            long buyerVotes = voteRepository.countByDisputeIdAndVoteSide(d.getId(), "buyer");
            BigDecimal rate = BigDecimal.valueOf(buyerVotes * 100.0 / totalVotes)
                    .setScale(2, RoundingMode.HALF_UP);
            d.setBuyerSupportRate(rate);

            if (rate.compareTo(new BigDecimal("66.00")) >= 0) {
                d.setResult("buyer_win");
                Order order = orderRepository.findById(d.getOrderId()).orElse(null);
                if (order != null) {
                    order.setAfterSaleStatus("returning");
                    orderRepository.save(order);
                }
            } else {
                d.setResult("seller_win");
            }
            d.setStatus("resolved");
            d.setUpdatedAt(LocalDateTime.now());
            disputeRepository.save(d);
        }
    }
}
