package com.nonheritage.demo.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

/** 审核日志实体类 */
@Entity
public class AuditLog {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;               // 主键
    private Long contentId;        // 被审核的内容ID
    private Long auditorId;        // 审核员（管理员）用户ID
    private String action;         // 操作：approve / reject
    private String reason;         // 审核意见/原因
    private LocalDateTime createdAt = LocalDateTime.now(); // 审核时间

    public AuditLog() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getContentId() { return contentId; }
    public void setContentId(Long contentId) { this.contentId = contentId; }
    public Long getAuditorId() { return auditorId; }
    public void setAuditorId(Long auditorId) { this.auditorId = auditorId; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
