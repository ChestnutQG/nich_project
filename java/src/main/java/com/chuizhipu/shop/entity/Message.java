package com.chuizhipu.shop.entity;

import java.time.LocalDateTime;

/**
 * 消息实体 — 支持聊天消息 & 系统通知
 */
public class Message {

    private Long id;
    private String conversationId;   // 会话ID，格式: "smallerId_largerId"（聊天消息）；null（通知消息）
    private Long senderId;           // 发送者ID（通知时可为系统ID 0）
    private Long receiverId;         // 接收者ID
    private String content;          // 消息/通知内容
    private String messageType;      // chat | notification
    private String notificationType; // dispute_new | dispute_status | dispute_resolved | jury_invite | system
    private Long relatedId;          // 关联ID（如维权ID、订单ID）
    private Boolean isRead;          // 是否已读
    private LocalDateTime createdAt;

    // ---- 关联字段（非数据库列） ----
    private String senderName;
    private String senderAvatar;

    // ===== Getters & Setters =====

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getConversationId() { return conversationId; }
    public void setConversationId(String conversationId) { this.conversationId = conversationId; }

    public Long getSenderId() { return senderId; }
    public void setSenderId(Long senderId) { this.senderId = senderId; }

    public Long getReceiverId() { return receiverId; }
    public void setReceiverId(Long receiverId) { this.receiverId = receiverId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }

    public String getNotificationType() { return notificationType; }
    public void setNotificationType(String notificationType) { this.notificationType = notificationType; }

    public Long getRelatedId() { return relatedId; }
    public void setRelatedId(Long relatedId) { this.relatedId = relatedId; }

    public Boolean getIsRead() { return isRead; }
    public void setIsRead(Boolean isRead) { this.isRead = isRead; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderAvatar() { return senderAvatar; }
    public void setSenderAvatar(String senderAvatar) { this.senderAvatar = senderAvatar; }
}
