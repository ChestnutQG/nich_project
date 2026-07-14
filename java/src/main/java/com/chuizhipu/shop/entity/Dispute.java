package com.chuizhipu.shop.entity;

import java.time.LocalDateTime;

/** 纠纷 / 小法庭 */
public class Dispute {
    private Long id;
    private Long orderId;
    private Long initiatorId;
    private Long respondentId;
    private String reason;
    private String evidenceUrls;     // JSON 数组
    private String status;           // negotiating | pending_jury | voting | resolved
    private String result;           // buyer_win | seller_win | null
    private Integer buyerVotes;
    private Integer sellerVotes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ---- 关联 ----
    private String orderNo;
    private Long productId;
    private String productName;
    private String initiatorName;
    private String respondentName;

    // getters/setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }
    public Long getInitiatorId() { return initiatorId; }
    public void setInitiatorId(Long initiatorId) { this.initiatorId = initiatorId; }
    public Long getRespondentId() { return respondentId; }
    public void setRespondentId(Long respondentId) { this.respondentId = respondentId; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getEvidenceUrls() { return evidenceUrls; }
    public void setEvidenceUrls(String evidenceUrls) { this.evidenceUrls = evidenceUrls; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getResult() { return result; }
    public void setResult(String result) { this.result = result; }
    public Integer getBuyerVotes() { return buyerVotes; }
    public void setBuyerVotes(Integer buyerVotes) { this.buyerVotes = buyerVotes; }
    public Integer getSellerVotes() { return sellerVotes; }
    public void setSellerVotes(Integer sellerVotes) { this.sellerVotes = sellerVotes; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public String getOrderNo() { return orderNo; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getInitiatorName() { return initiatorName; }
    public void setInitiatorName(String initiatorName) { this.initiatorName = initiatorName; }
    public String getRespondentName() { return respondentName; }
    public void setRespondentName(String respondentName) { this.respondentName = respondentName; }
}
