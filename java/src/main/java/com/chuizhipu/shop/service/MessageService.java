package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Message;
import com.chuizhipu.shop.mapper.MessageMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class MessageService {

    private final MessageMapper messageMapper;

    public MessageService(MessageMapper messageMapper) {
        this.messageMapper = messageMapper;
    }

    /** 发送聊天消息 */
    @Transactional
    public Message sendChatMessage(Long senderId, Long receiverId, String content) {
        Message msg = new Message();
        msg.setConversationId(buildConversationId(senderId, receiverId));
        msg.setSenderId(senderId);
        msg.setReceiverId(receiverId);
        msg.setContent(content);
        msg.setMessageType("chat");
        msg.setIsRead(false);
        msg.setCreatedAt(LocalDateTime.now());
        messageMapper.insert(msg);
        return msg;
    }

    /** 发送系统通知（指定接收者） */
    @Transactional
    public Message sendNotification(Long receiverId, String content,
                                     String notificationType, Long relatedId) {
        Message msg = new Message();
        msg.setSenderId(0L);  // 系统发送
        msg.setReceiverId(receiverId);
        msg.setContent(content);
        msg.setMessageType("notification");
        msg.setNotificationType(notificationType);
        msg.setRelatedId(relatedId);
        msg.setIsRead(false);
        msg.setCreatedAt(LocalDateTime.now());
        messageMapper.insert(msg);
        return msg;
    }

    /** 获取会话消息列表 */
    public List<Message> getConversationMessages(Long userId, Long peerId, int page, int pageSize) {
        String convId = buildConversationId(userId, peerId);
        int offset = (page - 1) * pageSize;
        return messageMapper.selectByConversation(convId, offset, pageSize);
    }

    /** 获取用户的所有会话列表 */
    public List<Message> getConversations(Long userId) {
        return messageMapper.selectConversations(userId);
    }

    /** 获取通知列表 */
    public List<Message> getNotifications(Long userId, int page, int pageSize) {
        int offset = (page - 1) * pageSize;
        return messageMapper.selectNotifications(userId, offset, pageSize);
    }

    /** 获取未读通知数 */
    public int getUnreadNotificationCount(Long userId) {
        return messageMapper.countUnreadNotifications(userId);
    }

    /** 获取未读聊天消息数 */
    public int getUnreadChatCount(Long userId) {
        return messageMapper.countUnreadChatMessages(userId);
    }

    /** 获取总未读数（通知 + 聊天） */
    public int getTotalUnreadCount(Long userId) {
        return messageMapper.countUnreadNotifications(userId) +
                messageMapper.countUnreadChatMessages(userId);
    }

    /** 标记通知已读 */
    @Transactional
    public void markNotificationRead(Long id) {
        messageMapper.markNotificationRead(id);
    }

    /** 标记某会话已读 */
    @Transactional
    public void markConversationRead(Long userId, Long peerId) {
        String convId = buildConversationId(userId, peerId);
        messageMapper.markConversationRead(convId, userId);
    }

    /** 全部通知标为已读 */
    @Transactional
    public void markAllNotificationsRead(Long userId) {
        messageMapper.markAllNotificationsRead(userId);
    }

    /** 生成会话ID（小ID在前，确保A-B和B-A是同一个会话） */
    private String buildConversationId(Long a, Long b) {
        return a < b ? a + "_" + b : b + "_" + a;
    }
}
