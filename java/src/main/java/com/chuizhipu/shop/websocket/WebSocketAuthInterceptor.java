package com.chuizhipu.shop.websocket;

import com.chuizhipu.shop.util.TokenUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

/**
 * WebSocket 握手拦截器 — 从 URL 参数 token 中提取 userId
 */
@Component
public class WebSocketAuthInterceptor implements HandshakeInterceptor {

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                   WebSocketHandler wsHandler, Map<String, Object> attributes) {
        if (request instanceof ServletServerHttpRequest servletRequest) {
            HttpServletRequest httpReq = servletRequest.getServletRequest();
            String token = httpReq.getParameter("token");
            if (token != null && !token.isEmpty()) {
                Long userId = TokenUtil.getUserId(token);
                if (userId != null) {
                    attributes.put("userId", userId);
                    return true;
                }
            }
            // 也尝试从 Authorization header 取
            String authHeader = httpReq.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                Long userId = TokenUtil.getUserId(authHeader.substring(7));
                if (userId != null) {
                    attributes.put("userId", userId);
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response,
                               WebSocketHandler wsHandler, Exception exception) {
        // no-op
    }
}
