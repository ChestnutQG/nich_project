package com.nonheritage.demo.config;

import com.nonheritage.demo.util.TokenUtil;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** 认证拦截器：校验Token，放行公开接口与OPTIONS预检请求 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final TokenUtil tokenUtil;

    public AuthInterceptor(TokenUtil tokenUtil) {
        this.tokenUtil = tokenUtil;
    }

    /** 请求预处理：验证Token或放行公开接口 */
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) return true;

        String path = request.getRequestURI();
        String method = request.getMethod();

        // 公开接口：登录、注册
        if (path.contains("/api/users/login") || path.contains("/api/users/register")) return true;

        // 公开接口：GET 浏览内容、商品、纠纷（无需登录即可查看）
        if ("GET".equals(method)) {
            if (path.matches("/api/contents(/\\d+)?") ||
                path.matches("/api/products(/\\d+)?") ||
                path.matches("/api/contents/tag/.*")) {
                return true;
            }
        }

        String auth = request.getHeader("Authorization");
        if (auth == null || !auth.startsWith("Bearer ")) {
            response.setStatus(401);
            return false;
        }

        String token = auth.substring(7);
        Long userId = tokenUtil.getUserId(token);
        if (userId == null) {
            response.setStatus(401);
            return false;
        }

        request.setAttribute("currentUserId", userId);
        return true;
    }
}
