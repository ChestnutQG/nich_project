package com.nonheritage.demo.dto;

/** 陪审团投票请求DTO */
public class VoteRequest {
    private Long disputeId;    // 纠纷ID
    private String voteSide;   // 投票立场：buyer / seller

    public Long getDisputeId() { return disputeId; }
    public void setDisputeId(Long disputeId) { this.disputeId = disputeId; }
    public String getVoteSide() { return voteSide; }
    public void setVoteSide(String voteSide) { this.voteSide = voteSide; }
}
