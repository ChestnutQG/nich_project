package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.Message;
import com.chuizhipu.shop.service.MessageService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    private Long getUserId(HttpServletRequest request) {
        return (Long) request.getAttribute("currentUserId");
    }

    // ==================== 聊天消息 ====================

    /** 发送聊天消息 */
    @PostMapping("/chat")
    public R sendChatMessage(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");

        try {
            Long receiverId = Long.valueOf(body.get("receiverId").toString());
            String content = (String) body.get("content");
            if (content == null || content.trim().isEmpty()) {
                return R.error("消息内容不能为空");
            }
            Message msg = messageService.sendChatMessage(userId, receiverId, content.trim());
            return R.ok(msg);
        } catch (Exception e) {
            return R.error("发送失败: " + e.getMessage());
        }
    }

    /** 获取与某用户的聊天记录 */
    @GetMapping("/chat/{peerId}")
    public R getChatMessages(HttpServletRequest request,
                              @PathVariable Long peerId,
                              @RequestParam(defaultValue = "1") int page,
                              @RequestParam(defaultValue = "50") int pageSize) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");

        List<Message> list = messageService.getConversationMessages(userId, peerId, page, pageSize);
        // 返回时反转顺序，让最早的消息在上面
        Collections.reverse(list);
        return R.ok(list);
    }

    /** 获取会话列表 */
    @GetMapping("/conversations")
    public R getConversations(HttpServletRequest request) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");

        List<Message> list = messageService.getConversations(userId);
        return R.ok(list);
    }

    /** 标记会话已读 */
    @PutMapping("/chat/{peerId}/read")
    public R markConversationRead(HttpServletRequest request, @PathVariable Long peerId) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");

        messageService.markConversationRead(userId, peerId);
        return R.ok();
    }

    // ==================== 通知消息 ====================

    /** 获取通知列表 */
    @GetMapping("/notifications")
    public R getNotifications(HttpServletRequest request,
                               @RequestParam(defaultValue = "1") int page,
                               @RequestParam(defaultValue = "20") int pageSize) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");

        List<Message> list = messageService.getNotifications(userId, page, pageSize);
        return R.ok(list);
    }

    /** 标记某条通知已读 */
    @PutMapping("/notification/{id}/read")
    public R markNotificationRead(HttpServletRequest request, @PathVariable Long id) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");

        messageService.markNotificationRead(id);
        return R.ok();
    }

    /** 全部通知标为已读 */
    @PutMapping("/notifications/read-all")
    public R markAllNotificationsRead(HttpServletRequest request) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");

        messageService.markAllNotificationsRead(userId);
        return R.ok();
    }

    // ==================== 未读数 ====================

    /** 获取总未读消息数 */
    @GetMapping("/unread-count")
    public R getUnreadCount(HttpServletRequest request) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("total", messageService.getTotalUnreadCount(userId));
        result.put("chat", messageService.getUnreadChatCount(userId));
        result.put("notification", messageService.getUnreadNotificationCount(userId));
        return R.ok(result);
    }
}
