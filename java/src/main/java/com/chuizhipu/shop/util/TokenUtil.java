package com.chuizhipu.shop.util;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Token 工具 — 基于 UUID 的轻量级令牌管理
 */
public class TokenUtil {

    private static final Map<String, Long> TOKEN_STORE = new ConcurrentHashMap<>();
    private static final Map<Long, String> USER_TOKENS = new ConcurrentHashMap<>(); // 一人一token

    public static String createToken(Long userId) {
        // 旧 token 作废
        String oldToken = USER_TOKENS.remove(userId);
        if (oldToken != null) {
            TOKEN_STORE.remove(oldToken);
        }
        String token = UUID.randomUUID().toString().replace("-", "");
        TOKEN_STORE.put(token, userId);
        USER_TOKENS.put(userId, token);
        return token;
    }

    public static Long getUserId(String token) {
        if (token == null || token.isEmpty()) return null;
        return TOKEN_STORE.get(token);
    }

    public static void removeToken(String token) {
        Long userId = TOKEN_STORE.remove(token);
        if (userId != null) {
            USER_TOKENS.remove(userId);
        }
    }

    public static void removeTokenByUserId(Long userId) {
        String token = USER_TOKENS.remove(userId);
        if (token != null) {
            TOKEN_STORE.remove(token);
        }
    }
}
