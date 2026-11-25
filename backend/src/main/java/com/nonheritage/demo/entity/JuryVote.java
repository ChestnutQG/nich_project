package com.nonheritage.demo.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

/** 陪审团投票实体类 */
@Entity
public class JuryVote {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;               // 主键
    private Long disputeId;        // 关联纠纷ID
    private Long voterId;          // 投票人用户ID
    private String voteSide;       // 投票立场：buyer / seller
    private LocalDateTime voteTime = LocalDateTime.now(); // 投票时间

    public JuryVote() {}

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
