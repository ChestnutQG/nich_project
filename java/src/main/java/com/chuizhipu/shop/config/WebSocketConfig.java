package com.chuizhipu.shop.config;

import com.chuizhipu.shop.websocket.ChatWebSocketHandler;
import com.chuizhipu.shop.websocket.WebSocketAuthInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final ChatWebSocketHandler chatHandler;
    private final WebSocketAuthInterceptor wsAuthInterceptor;

    public WebSocketConfig(ChatWebSocketHandler chatHandler,
                           WebSocketAuthInterceptor wsAuthInterceptor) {
        this.chatHandler = chatHandler;
        this.wsAuthInterceptor = wsAuthInterceptor;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(chatHandler, "/ws/chat")
                .addInterceptors(wsAuthInterceptor)
                .setAllowedOrigins("*");
    }
}
