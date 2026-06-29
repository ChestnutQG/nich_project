package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Notification;
import com.chuizhipu.shop.mapper.NotificationMapper;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 系统通知服务 — 供各业务在关键事件时调用 notify(...)
 */
@Service
public class NotificationService {

    private final NotificationMapper notificationMapper;

    public NotificationService(NotificationMapper notificationMapper) {
        this.notificationMapper = notificationMapper;
    }

    /** 便捷重载：按类型自动取标题（兼容各业务的通知调用） */
    public void notify(Long userId, String type, String content, Long refId) {
        notify(userId, type, titleOf(type), content, refId);
    }

    /** 根据通知类型给一个默认标题 */
    private String titleOf(String type) {
        if (type == null) return "通知";
        switch (type) {
            case "order":
            case "order_status": return "订单通知";
            case "follow": return "新增关注";
            case "comment": return "新评论";
            case "artisan_new": return "匠人上新";
            case "price_drop": return "降价提醒";
            case "jury_invite": return "陪审邀请";
            default:
                if (type.startsWith("dispute")) return "维权通知";
                return "通知";
        }
    }

    /** 写一条通知（业务事件触发，失败不影响主流程） */
    public void notify(Long userId, String type, String title, String content, Long refId) {
        if (userId == null) return;
        try {
            Notification n = new Notification();
            n.setUserId(userId);
            n.setType(type);
            n.setTitle(title);
            n.setContent(content);
            n.setRefId(refId);
            notificationMapper.insert(n);
        } catch (Exception ignore) {
            // 通知失败不影响业务
        }
    }

    public List<Map<String, Object>> getList(Long userId) {
        List<Notification> list = notificationMapper.selectByUserId(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Notification n : list) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", n.getId().toString());
            m.put("type", n.getType());
            m.put("title", n.getTitle());
            m.put("content", n.getContent() != null ? n.getContent() : "");
            m.put("refId", n.getRefId() != null ? n.getRefId().toString() : "");
            m.put("isRead", n.getIsRead() != null && n.getIsRead() == 1);
            m.put("time", relativeTime(n.getCreateTime()));
            result.add(m);
        }
        return result;
    }

    public int unreadCount(Long userId) {
        return notificationMapper.countUnread(userId);
    }

    public void markRead(Long id, Long userId) {
        notificationMapper.markRead(id, userId);
    }

    public void markAllRead(Long userId) {
        notificationMapper.markAllRead(userId);
    }

    private String relativeTime(LocalDateTime time) {
        if (time == null) return "";
        Duration d = Duration.between(time, LocalDateTime.now());
        long mins = d.toMinutes();
        if (mins < 1) return "刚刚";
        if (mins < 60) return mins + "分钟前";
        long hours = d.toHours();
        if (hours < 24) return hours + "小时前";
        long days = d.toDays();
        if (days < 30) return days + "天前";
        return time.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }
}
