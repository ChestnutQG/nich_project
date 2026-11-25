package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.service.CommentService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 商品评论接口
 */
@RestController
@RequestMapping("/api/products")
public class CommentController {

    private final CommentService commentService;

    public CommentController(CommentService commentService) {
        this.commentService = commentService;
    }

    /** GET /api/products/{productId}/comments — 评论列表（公开） */
    @GetMapping("/{productId}/comments")
    public R list(@PathVariable Long productId) {
        List<Map<String, Object>> list = commentService.getComments(productId);
        return R.ok(list);
    }

    /** POST /api/products/{productId}/comments — 发表评论（需登录） */
    @PostMapping("/{productId}/comments")
    public R add(HttpServletRequest request, @PathVariable Long productId,
                 @RequestBody CommentReq req) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        if (req.getContent() == null || req.getContent().isBlank()) {
            return R.error("评论内容不能为空");
        }
        Long id = commentService.addComment(userId, productId, req.getContent().trim());
        return R.ok(id);
    }

    public static class CommentReq {
        private String content;
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
    }
}
