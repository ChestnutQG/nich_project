package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Message;
import com.chuizhipu.shop.mapper.MessageMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 私信服务
 */
@Service
public class MessageService {

    private final MessageMapper messageMapper;

    public MessageService(MessageMapper messageMapper) {
        this.messageMapper = messageMapper;
    }

    /** 发私信 */
    public Long send(Long fromId, Long toId, String content) {
        Message m = new Message();
        m.setFromUserId(fromId);
        m.setToUserId(toId);
        m.setContent(content);
        messageMapper.insert(m);
        return m.getId();
    }

    /** 取与某人的聊天记录，并把对方发来的标记为已读 */
    @Transactional
    public List<Map<String, Object>> getConversation(Long userId, Long otherId) {
        messageMapper.markConversationRead(userId, otherId);
        List<Message> list = messageMapper.selectConversation(userId, otherId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Message m : list) {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", m.getId().toString());
            map.put("fromMe", m.getFromUserId().equals(userId));
            map.put("content", m.getContent());
            map.put("time", formatTime(m.getCreateTime()));
            result.add(map);
        }
        return result;
    }

    /** 会话列表 */
    public List<Map<String, Object>> getConversationList(Long userId) {
        List<Map<String, Object>> raw = messageMapper.selectConversationList(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> r : raw) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("otherId", String.valueOf(r.get("otherId")));
            m.put("otherName", r.get("otherName") != null ? r.get("otherName") : "用户");
            m.put("otherAvatar", r.get("otherAvatar") != null ? r.get("otherAvatar") : "");
            m.put("lastContent", r.get("lastContent") != null ? r.get("lastContent") : "");
            Object unread = r.get("unread");
            m.put("unread", unread == null ? 0 : ((Number) unread).intValue());
            Object lastTime = r.get("lastTime");
            m.put("time", lastTime instanceof LocalDateTime ? relativeTime((LocalDateTime) lastTime) : "");
            result.add(m);
        }
        return result;
    }

    public int unreadCount(Long userId) {
        return messageMapper.countUnread(userId);
    }

    private String formatTime(LocalDateTime t) {
        if (t == null) return "";
        return t.format(DateTimeFormatter.ofPattern("MM-dd HH:mm"));
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
