package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Artisan;
import com.chuizhipu.shop.entity.Comment;
import com.chuizhipu.shop.entity.Product;
import com.chuizhipu.shop.entity.User;
import com.chuizhipu.shop.mapper.ArtisanMapper;
import com.chuizhipu.shop.mapper.CommentMapper;
import com.chuizhipu.shop.mapper.ProductMapper;
import com.chuizhipu.shop.mapper.UserMapper;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 商品评论服务
 */
@Service
public class CommentService {

    private final CommentMapper commentMapper;
    private final ProductMapper productMapper;
    private final ArtisanMapper artisanMapper;
    private final UserMapper userMapper;
    private final NotificationService notificationService;

    public CommentService(CommentMapper commentMapper, ProductMapper productMapper,
                          ArtisanMapper artisanMapper, UserMapper userMapper,
                          NotificationService notificationService) {
        this.commentMapper = commentMapper;
        this.productMapper = productMapper;
        this.artisanMapper = artisanMapper;
        this.userMapper = userMapper;
        this.notificationService = notificationService;
    }

    /** 发表评论 */
    public Long addComment(Long userId, Long productId, String content) {
        Comment c = new Comment();
        c.setUserId(userId);
        c.setProductId(productId);
        c.setContent(content);
        commentMapper.insert(c);
        notifyArtisan(userId, productId, content);
        return c.getId();
    }

    /** 通知作品所属匠人：有人评论了你的作品（接入站内通知系统） */
    private void notifyArtisan(Long commenterId, Long productId, String content) {
        try {
            Product p = productMapper.selectById(productId);
            if (p == null || p.getArtisanId() == null) return;
            Artisan a = artisanMapper.selectById(p.getArtisanId());
            if (a == null || a.getUserId() == null) return;
            if (a.getUserId().equals(commenterId)) return; // 自评不通知
            User commenter = userMapper.selectById(commenterId);
            String who = commenter != null && commenter.getNickname() != null ? commenter.getNickname() : "有人";
            String msg = who + " 评论了你的作品《" + p.getName() + "》：" + content;
            notificationService.notify(a.getUserId(), "comment", msg, productId);
        } catch (Exception ignore) {
            // 通知失败不影响评论
        }
    }

    /** 某商品的评论列表（字段对齐前端 Comment 接口） */
    public List<Map<String, Object>> getComments(Long productId) {
        List<Comment> list = commentMapper.selectByProductId(productId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Comment c : list) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", c.getId().toString());
            m.put("userId", c.getUserId() != null ? c.getUserId().toString() : "");
            m.put("userName", c.getUserName() != null ? c.getUserName() : "用户");
            m.put("avatar", c.getAvatar() != null ? c.getAvatar() : "");
            m.put("content", c.getContent());
            m.put("time", relativeTime(c.getCreateTime()));
            result.add(m);
        }
        return result;
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
