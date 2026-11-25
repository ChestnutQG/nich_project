package com.chuizhipu.shop.entity;

import java.time.LocalDateTime;

/** 陪审投票 */
public class JuryVote {
    private Long id;
    private Long disputeId;
    private Long voterId;
    private String voteSide;     // buyer | seller
    private LocalDateTime voteTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getDisputeId() { return disputeId; }
    public void setDisputeId(Long disputeId) { this.disputeId = disputeId; }
    public Long getVoterId() { return voterId; }
    public void setVoterId(Long voterId) { this.voterId = voterId; }
    public String getVoteSide() { return voteSide; }
    public void setVoteSide(String voteSide) { this.voteSide = voteSide; }
    public LocalDateTime getVoteTime() { return voteTime; }
    public void setVoteTime(LocalDateTime voteTime) { this.voteTime = voteTime; }
}
