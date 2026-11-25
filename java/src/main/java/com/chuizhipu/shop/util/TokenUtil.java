package com.chuizhipu.shop.util;

import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Token 工具 — 基于 UUID 的轻量级令牌管理
 */
public class TokenUtil {

    private static final Map<String, Long> TOKEN_STORE = new ConcurrentHashMap<>();
    /** 同一用户可同时在 App、管理端等多个终端登录。 */
    private static final Map<Long, Set<String>> USER_TOKENS = new ConcurrentHashMap<>();

    public static synchronized String createToken(Long userId) {
        String token = UUID.randomUUID().toString().replace("-", "");
        TOKEN_STORE.put(token, userId);
        USER_TOKENS.computeIfAbsent(userId, id -> ConcurrentHashMap.newKeySet()).add(token);
        return token;
    }

    public static Long getUserId(String token) {
        if (token == null || token.isEmpty()) return null;
        return TOKEN_STORE.get(token);
    }

    public static synchronized void removeToken(String token) {
        Long userId = TOKEN_STORE.remove(token);
        if (userId != null) {
            Set<String> tokens = USER_TOKENS.get(userId);
            if (tokens != null) {
                tokens.remove(token);
                if (tokens.isEmpty()) {
                    USER_TOKENS.remove(userId, tokens);
                }
            }
        }
    }

    public static synchronized void removeTokenByUserId(Long userId) {
        Set<String> tokens = USER_TOKENS.remove(userId);
        if (tokens != null) {
            tokens.forEach(TOKEN_STORE::remove);
        }
    }
}
