package com.nonheritage.demo.util;

import org.springframework.stereotype.Component;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/** 简易Token工具：基于UUID生成token，ConcurrentHashMap存储（学习用，生产需用JWT） */
@Component
public class TokenUtil {
    private final Map<String, Long> tokenStore = new ConcurrentHashMap<>();
    private final Map<Long, String> reverseStore = new ConcurrentHashMap<>();

    /** 创建token，覆盖用户旧token @param userId 用户ID @return UUID字符串token */
    public String createToken(Long userId) {
        String old = reverseStore.remove(userId);
        if (old != null) tokenStore.remove(old);

        String token = UUID.randomUUID().toString().replace("-", "");
        tokenStore.put(token, userId);
        reverseStore.put(userId, token);
        return token;
    }

    /** 根据token获取用户ID @param token 请求头中的token @return 用户ID或null */
    public Long getUserId(String token) {
        return token != null ? tokenStore.get(token) : null;
    }

    /** 移除token（退出登录） @param token 要移除的token */
    public void removeToken(String token) {
        Long uid = tokenStore.remove(token);
        if (uid != null) reverseStore.remove(uid);
    }
}
