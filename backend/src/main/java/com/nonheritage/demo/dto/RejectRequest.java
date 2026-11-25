package com.nonheritage.demo.dto;

/** 驳回请求DTO（审核驳回/纠纷驳回） */
public class RejectRequest {
    private String reason; // 驳回原因

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
}
