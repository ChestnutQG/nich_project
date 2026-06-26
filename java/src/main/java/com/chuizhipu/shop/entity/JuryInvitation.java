package com.chuizhipu.shop.entity;

import java.time.LocalDateTime;

/** 陪审邀请 */
public class JuryInvitation {
    private Long id;
    private Long disputeId;
    private Long userId;
    private String status;       // pending | voted
    private LocalDateTime inviteTime;
    private LocalDateTime voteTime;

    // ---- 关联 ----
    private String disputeReason;
    private String userName;

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
    public String getDisputeReason() { return disputeReason; }
    public void setDisputeReason(String disputeReason) { this.disputeReason = disputeReason; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
}
