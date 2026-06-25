package com.nonheritage.demo.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

/** 陪审团邀请实体类 */
@Entity
public class JuryInvitation {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;               // 主键
    private Long disputeId;        // 关联纠纷ID
    private Long userId;           // 被邀请的陪审员用户ID
    private String status = "pending"; // 邀请状态：pending / accepted / declined
    private LocalDateTime inviteTime = LocalDateTime.now(); // 邀请时间
    private LocalDateTime voteTime; // 投票时间

    public JuryInvitation() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getDisputeId() { return disputeId; }
    public void setDisputeId(Long disputeId) { this.disputeId = disputeId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getInviteTime() { return inviteTime; }
    public void setInviteTime(LocalDateTime inviteTime) { this.inviteTime = inviteTime; }
    public LocalDateTime getVoteTime() { return voteTime; }
    public void setVoteTime(LocalDateTime voteTime) { this.voteTime = voteTime; }
}
