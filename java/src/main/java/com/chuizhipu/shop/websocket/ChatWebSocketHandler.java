package com.chuizhipu.shop.websocket;

import com.chuizhipu.shop.entity.Message;
import com.chuizhipu.shop.service.MessageService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 聊天 WebSocket 处理器 — 维护在线用户连接，实时转发聊天消息
 */
@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private static final Logger log = LoggerFactory.getLogger(ChatWebSocketHandler.class);
    private static final ObjectMapper mapper = new ObjectMapper();

    /** userId -> WebSocketSession */
    private static final Map<Long, WebSocketSession> onlineUsers = new ConcurrentHashMap<>();

    private final MessageService messageService;

    public ChatWebSocketHandler(MessageService messageService) {
        this.messageService = messageService;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            onlineUsers.put(userId, session);
            log.info("WebSocket connected: userId={}", userId);

            // 通知对方自己上线了
            sendJson(session, Map.of("type", "connected", "userId", userId));
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage textMessage) {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId == null) return;

        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> payload = mapper.readValue(textMessage.getPayload(), Map.class);

            String msgType = (String) payload.get("type");
            if ("chat".equals(msgType)) {
                // 聊天消息: { type: "chat", receiverId: 123, content: "你好" }
                Long receiverId = Long.valueOf(payload.get("receiverId").toString());
                String content = (String) payload.get("content");
                if (content == null || content.trim().isEmpty()) return;

                // 持久化
                Message msg = messageService.sendChatMessage(userId, receiverId, content.trim());

                // 构造响应
                Map<String, Object> resp = Map.of(
                        "type", "chat",
                        "id", msg.getId(),
                        "senderId", userId,
                        "receiverId", receiverId,
                        "content", msg.getContent(),
                        "createdAt", msg.getCreatedAt() != null ? msg.getCreatedAt().toString() : ""
                );

                // 发送给发送者（确认）
                sendJson(session, resp);

                // 推送给接收者（如果在线）
                WebSocketSession receiverSession = onlineUsers.get(receiverId);
                if (receiverSession != null && receiverSession.isOpen()) {
                    sendJson(receiverSession, resp);
                }
            } else if ("ping".equals(msgType)) {
                sendJson(session, Map.of("type", "pong"));
            }
        } catch (Exception e) {
            log.error("WebSocket message error: {}", e.getMessage());
            sendJson(session, Map.of("type", "error", "message", e.getMessage()));
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            onlineUsers.remove(userId);
            log.info("WebSocket disconnected: userId={}", userId);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        log.error("WebSocket transport error: {}", exception.getMessage());
        Long userId = (Long) session.getAttributes().get("userId");
        if (userId != null) {
            onlineUsers.remove(userId);
        }
    }

    /** 向指定用户推送消息（供外部调用，如通知推送） */
    public void pushToUser(Long userId, Object message) {
        WebSocketSession session = onlineUsers.get(userId);
        if (session != null && session.isOpen()) {
            sendJson(session, message);
        }
    }

    /** 检查用户是否在线 */
    public boolean isUserOnline(Long userId) {
        WebSocketSession session = onlineUsers.get(userId);
        return session != null && session.isOpen();
    }

    private void sendJson(WebSocketSession session, Object data) {
        try {
            if (session.isOpen()) {
                session.sendMessage(new TextMessage(mapper.writeValueAsString(data)));
            }
        } catch (IOException e) {
            log.error("Failed to send WebSocket message: {}", e.getMessage());
        }
    }
}
