package com.nonheritage.demo.entity;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 纠纷/争议实体类（小法庭维权） */
@Entity
public class Dispute {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;               // 主键
    private Long orderId;          // 关联订单ID
    private Long initiatorId;      // 发起方用户ID（原告）
    private Long respondentId;     // 被诉方用户ID（被告）
    @Column(columnDefinition = "TEXT")
    private String reason;         // 纠纷原因描述
    @Column(columnDefinition = "TEXT")
    private String evidenceUrls;   // 证据图片URL（JSON数组字符串）
    private String status = "negotiating"; // 状态：negotiating / jury / resolved
    private String result;         // 裁决结果：buyer_win / seller_win / tie
    private BigDecimal buyerSupportRate; // 买家支持率（陪审团投票比例）
    private LocalDateTime createdAt = LocalDateTime.now(); // 创建时间
    private LocalDateTime updatedAt = LocalDateTime.now(); // 更新时间

    public Dispute() {}

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
    public BigDecimal getBuyerSupportRate() { return buyerSupportRate; }
    public void setBuyerSupportRate(BigDecimal buyerSupportRate) { this.buyerSupportRate = buyerSupportRate; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
