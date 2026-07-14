package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.CartItem;
import com.chuizhipu.shop.service.CartService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cart")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    private Long getUserId(HttpServletRequest request) {
        return (Long) request.getAttribute("currentUserId");
    }

    /** GET /api/cart — 购物车列表 */
    @GetMapping
    public R list(HttpServletRequest request) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");
        List<Map<String, Object>> items = cartService.getCartItems(userId);
        return R.ok(items);
    }

    /** POST /api/cart — 加入购物车 */
    @PostMapping
    public R add(HttpServletRequest request, @RequestBody CartItem item) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");
        item.setUserId(userId);
        cartService.addToCart(item);
        return R.ok(null);
    }

    /** PUT /api/cart/{id} — 更新数量 */
    @PutMapping("/{id}")
    public R updateQuantity(HttpServletRequest request, @PathVariable Long id,
                            @RequestBody Map<String, Integer> body) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");
        cartService.updateQuantity(id, body.get("quantity"));
        return R.ok(null);
    }

    /** PUT /api/cart/{id}/checked — 勾选/取消 */
    @PutMapping("/{id}/checked")
    public R updateChecked(@PathVariable Long id,
                           @RequestBody Map<String, Integer> body) {
        cartService.updateChecked(id, body.get("isChecked"));
        return R.ok(null);
    }

    /** PUT /api/cart/check-all — 全选/取消全选 */
    @PutMapping("/check-all")
    public R checkAll(HttpServletRequest request,
                      @RequestBody Map<String, Integer> body) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");
        cartService.updateAllChecked(userId, body.get("isChecked"));
        return R.ok(null);
    }

    /** DELETE /api/cart/{id} — 删除 */
    @DeleteMapping("/{id}")
    public R remove(@PathVariable Long id) {
        cartService.removeItem(id);
        return R.ok(null);
    }

    /** GET /api/cart/count — 购物车数量 */
    @GetMapping("/count")
    public R count(HttpServletRequest request) {
        Long userId = getUserId(request);
        if (userId == null) return R.ok(0);
        int count = cartService.getCartCount(userId);
        return R.ok(count);
    }
}
