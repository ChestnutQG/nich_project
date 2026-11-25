package com.nonheritage.demo.dto;

/** 发起纠纷请求DTO */
public class DisputeRequest {
    private Long orderId;       // 订单ID
    private String reason;      // 纠纷原因
    private String evidenceUrls; // 证据图片URL（JSON数组字符串）

    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getEvidenceUrls() { return evidenceUrls; }
    public void setEvidenceUrls(String evidenceUrls) { this.evidenceUrls = evidenceUrls; }
}
