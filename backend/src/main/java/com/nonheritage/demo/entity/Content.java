package com.nonheritage.demo.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

/** 非遗内容实体类（帖子/文章） */
@Entity
public class Content {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;               // 主键
    private Long userId;           // 发布者用户ID
    private String title;          // 标题
    @Column(columnDefinition = "TEXT")
    private String description;    // 正文描述
    private String type;           // 类型：image / video
    @Column(columnDefinition = "TEXT")
    private String mediaUrls;      // 媒体资源URL（JSON数组字符串）
    private String tags;           // 标签（逗号分隔）
    private String status = "draft";    // 状态：draft / pending / approved / rejected
    private String rejectReason;   // 驳回原因
    private Integer likeCount = 0; // 点赞数
    private Integer viewCount = 0; // 浏览数
    private Boolean isSellable = false; // 是否可售卖（关联商品）
    private LocalDateTime createdAt = LocalDateTime.now(); // 创建时间

    public Content() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getMediaUrls() { return mediaUrls; }
    public void setMediaUrls(String mediaUrls) { this.mediaUrls = mediaUrls; }
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }
    public Integer getLikeCount() { return likeCount; }
    public void setLikeCount(Integer likeCount) { this.likeCount = likeCount; }
    public Integer getViewCount() { return viewCount; }
    public void setViewCount(Integer viewCount) { this.viewCount = viewCount; }
    public Boolean getIsSellable() { return isSellable; }
    public void setIsSellable(Boolean isSellable) { this.isSellable = isSellable; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
