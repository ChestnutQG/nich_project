package com.nonheritage.demo.dto;

/** 内容发布/编辑请求DTO */
public class ContentRequest {
    private String title;       // 标题
    private String description; // 正文描述
    private String type;        // 类型：image / video
    private String mediaUrls;   // 媒体URL（JSON数组字符串）
    private String tags;        // 标签
    private Boolean isSellable; // 是否可售卖

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
    public Boolean getIsSellable() { return isSellable; }
    public void setIsSellable(Boolean isSellable) { this.isSellable = isSellable; }
}
