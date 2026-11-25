package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.service.FavoriteService;
import com.chuizhipu.shop.vo.ProductVO;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 商品收藏接口
 */
@RestController
@RequestMapping("/api/favorites")
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    /** GET /api/favorites — 我的收藏列表 */
    @GetMapping
    public R list(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        List<ProductVO> list = favoriteService.getMyFavorites(userId);
        return R.ok(list);
    }

    /** POST /api/favorites — 添加收藏 */
    @PostMapping
    public R add(HttpServletRequest request, @RequestBody FavReq req) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        if (req.getProductId() == null) return R.error("缺少商品ID");
        favoriteService.add(userId, req.getProductId());
        return R.ok(null);
    }

    /** DELETE /api/favorites/{productId} — 取消收藏 */
    @DeleteMapping("/{productId}")
    public R remove(HttpServletRequest request, @PathVariable Long productId) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        favoriteService.remove(userId, productId);
        return R.ok(null);
    }

    // 收藏请求体
    public static class FavReq {
        private Long productId;
        public Long getProductId() { return productId; }
        public void setProductId(Long productId) { this.productId = productId; }
    }
}
