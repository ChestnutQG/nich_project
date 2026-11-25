package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.service.NotificationService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 系统通知接口
 */
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    private Long uid(HttpServletRequest request) {
        return (Long) request.getAttribute("currentUserId");
    }

    /** GET /api/notifications — 我的通知列表 */
    @GetMapping
    public R list(HttpServletRequest request) {
        Long userId = uid(request);
        if (userId == null) return R.error(401, "请先登录");
        List<Map<String, Object>> list = notificationService.getList(userId);
        return R.ok(list);
    }

    /** GET /api/notifications/unread-count — 未读数 */
    @GetMapping("/unread-count")
    public R unread(HttpServletRequest request) {
        Long userId = uid(request);
        if (userId == null) return R.ok(0);
        return R.ok(notificationService.unreadCount(userId));
    }

    /** PUT /api/notifications/{id}/read — 标记已读 */
    @PutMapping("/{id}/read")
    public R read(HttpServletRequest request, @PathVariable Long id) {
        Long userId = uid(request);
        if (userId == null) return R.error(401, "请先登录");
        notificationService.markRead(id, userId);
        return R.ok(null);
    }

    /** PUT /api/notifications/read-all — 全部已读 */
    @PutMapping("/read-all")
    public R readAll(HttpServletRequest request) {
        Long userId = uid(request);
        if (userId == null) return R.error(401, "请先登录");
        notificationService.markAllRead(userId);
        return R.ok(null);
    }
}
