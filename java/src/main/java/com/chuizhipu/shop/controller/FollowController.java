package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.service.FollowService;
import com.chuizhipu.shop.vo.ArtisanVO;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 匠人关注接口
 */
@RestController
@RequestMapping("/api/follows")
public class FollowController {

    private final FollowService followService;

    public FollowController(FollowService followService) {
        this.followService = followService;
    }

    /** GET /api/follows — 我关注的匠人列表 */
    @GetMapping
    public R list(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        List<ArtisanVO> list = followService.getMyFollows(userId);
        return R.ok(list);
    }

    /** POST /api/follows — 关注匠人 */
    @PostMapping
    public R follow(HttpServletRequest request, @RequestBody FollowReq req) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        if (req.getArtisanId() == null) return R.error("缺少匠人ID");
        followService.follow(userId, req.getArtisanId());
        return R.ok(null);
    }

    /** DELETE /api/follows/{artisanId} — 取消关注 */
    @DeleteMapping("/{artisanId}")
    public R unfollow(HttpServletRequest request, @PathVariable Long artisanId) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        followService.unfollow(userId, artisanId);
        return R.ok(null);
    }

    // 关注请求体
    public static class FollowReq {
        private Long artisanId;
        public Long getArtisanId() { return artisanId; }
        public void setArtisanId(Long artisanId) { this.artisanId = artisanId; }
    }
}
