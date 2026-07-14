package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.service.MessageService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 私信接口
 */
@RestController
@RequestMapping("/api/messages")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    private Long uid(HttpServletRequest request) {
        return (Long) request.getAttribute("currentUserId");
    }

    /** GET /api/messages/conversations — 会话列表 */
    @GetMapping("/conversations")
    public R conversations(HttpServletRequest request) {
        Long userId = uid(request);
        if (userId == null) return R.error(401, "请先登录");
        List<Map<String, Object>> list = messageService.getConversationList(userId);
        return R.ok(list);
    }

    /** GET /api/messages/unread-count — 未读私信总数 */
    @GetMapping("/unread-count")
    public R unread(HttpServletRequest request) {
        Long userId = uid(request);
        if (userId == null) return R.ok(0);
        return R.ok(messageService.unreadCount(userId));
    }

    /** GET /api/messages/{otherId} — 与某人的聊天记录 */
    @GetMapping("/{otherId}")
    public R conversation(HttpServletRequest request, @PathVariable Long otherId) {
        Long userId = uid(request);
        if (userId == null) return R.error(401, "请先登录");
        List<Map<String, Object>> list = messageService.getConversation(userId, otherId);
        return R.ok(list);
    }

    /** POST /api/messages — 发私信 { toUserId, content } */
    @PostMapping
    public R send(HttpServletRequest request, @RequestBody SendReq req) {
        Long userId = uid(request);
        if (userId == null) return R.error(401, "请先登录");
        if (req.getToUserId() == null) return R.error("缺少接收者");
        if (req.getContent() == null || req.getContent().isBlank()) {
            return R.error("内容不能为空");
        }
        if (req.getToUserId().equals(userId)) return R.error("不能给自己发消息");
        Long id = messageService.send(userId, req.getToUserId(), req.getContent().trim());
        return R.ok(id);
    }

    public static class SendReq {
        private Long toUserId;
        private String content;
        public Long getToUserId() { return toUserId; }
        public void setToUserId(Long toUserId) { this.toUserId = toUserId; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
    }
}
