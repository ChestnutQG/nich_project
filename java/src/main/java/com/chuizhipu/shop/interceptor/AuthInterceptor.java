package com.chuizhipu.shop.interceptor;

import com.chuizhipu.shop.util.TokenUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 认证拦截器 — 校验 Bearer Token，注入 currentUserId
 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) throws Exception {
        // OPTIONS 预检放行
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String path = request.getRequestURI();

        // 公开路由 — 无需登录，但仍尽力解析 token，
        // 这样已登录用户访问商品详情等公开接口时也能拿到个性化字段（如收藏状态 isCollect）
        if (isPublicPath(path, request.getMethod())) {
            String header = request.getHeader("Authorization");
            if (header != null && header.startsWith("Bearer ")) {
                Long uid = TokenUtil.getUserId(header.substring(7));
                if (uid != null) {
                    request.setAttribute("currentUserId", uid);
                }
            }
            return true;
        }

        // 从 Authorization 头取 token
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"message\":\"请先登录\",\"data\":null}");
            return false;
        }

        String token = authHeader.substring(7);
        Long userId = TokenUtil.getUserId(token);
        if (userId == null) {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"message\":\"登录已过期，请重新登录\",\"data\":null}");
            return false;
        }

        request.setAttribute("currentUserId", userId);
        return true;
    }

    private boolean isPublicPath(String path, String method) {
        // 完全公开
        if (path.equals("/api/ping")) return true;
        if (path.equals("/api/users/login")) return true;
        if (path.equals("/api/users/register")) return true;
        if (path.equals("/api/upload")) return true;

        // 需登录的路径（GET 也不能公开）
        if (path.startsWith("/api/cart")) return false;
        if (path.startsWith("/api/favorites")) return false;
        if (path.startsWith("/api/orders") && "GET".equalsIgnoreCase(method)) return false;
        if (path.startsWith("/api/addresses") && "GET".equalsIgnoreCase(method)) return false;
        if (path.equals("/api/users/me")) return false;
        if (path.equals("/api/users/logout")) return false;
        if (path.startsWith("/api/disputes")) return false;
        if (path.startsWith("/api/jury")) return false;
        if (path.startsWith("/api/admin")) return false;

        // 其余 GET 公开（浏览商品、匠人、分类无需登录）
        if ("GET".equalsIgnoreCase(method)) return true;

        return false;
    }
}
