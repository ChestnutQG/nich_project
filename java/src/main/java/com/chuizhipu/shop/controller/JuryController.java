package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.JuryInvitation;
import com.chuizhipu.shop.service.DisputeService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/jury")
public class JuryController {

    private final DisputeService disputeService;

    public JuryController(DisputeService disputeService) {
        this.disputeService = disputeService;
    }

    private Long getUserId(HttpServletRequest request) {
        return (Long) request.getAttribute("currentUserId");
    }

    /** GET /api/jury/invitations/mine — 我的陪审邀请 */
    @GetMapping("/invitations/mine")
    public R myInvitations(HttpServletRequest request) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");
        List<JuryInvitation> list = disputeService.getMyInvitations(userId);
        return R.ok(list);
    }

    /** POST /api/jury/votes — 陪审投票 */
    @PostMapping("/votes")
    public R vote(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");
        try {
            Long disputeId = Long.valueOf(body.get("disputeId").toString());
            String voteSide = (String) body.get("voteSide");
            disputeService.vote(disputeId, userId, voteSide);
            return R.ok(null);
        } catch (IllegalArgumentException e) {
            return R.error(e.getMessage());
        }
    }
}
