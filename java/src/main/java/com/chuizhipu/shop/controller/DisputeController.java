package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.Dispute;
import com.chuizhipu.shop.entity.JuryInvitation;
import com.chuizhipu.shop.service.DisputeService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/disputes")
public class DisputeController {

    private final DisputeService disputeService;

    public DisputeController(DisputeService disputeService) {
        this.disputeService = disputeService;
    }

    private Long getUserId(HttpServletRequest request) {
        return (Long) request.getAttribute("currentUserId");
    }

    /** POST /api/disputes — 创建维权 */
    @PostMapping
    public R create(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");
        try {
            Long orderId = Long.valueOf(body.get("orderId").toString());
            String reason = (String) body.get("reason");
            String evidenceUrls = (String) body.get("evidenceUrls");
            Long id = disputeService.createDispute(orderId, userId, reason, evidenceUrls);
            return R.ok(id);
        } catch (IllegalArgumentException e) {
            return R.error(e.getMessage());
        } catch (Exception e) {
            return R.error("维权失败: " + e.getMessage());
        }
    }

    /** PUT /api/disputes/{id}/request-jury — 申请陪审团 */
    @PutMapping("/{id}/request-jury")
    public R requestJury(HttpServletRequest request, @PathVariable Long id) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");
        try {
            disputeService.requestJury(id, userId);
            return R.ok(null);
        } catch (IllegalArgumentException e) {
            return R.error(e.getMessage());
        } catch (Exception e) {
            return R.error("操作失败: " + e.getMessage());
        }

    /** GET /api/disputes/{id} — 纠纷详情 */
    @GetMapping("/{id}")
    public R detail(@PathVariable Long id) {
        Dispute dispute = disputeService.getById(id);
        if (dispute == null) return R.error("纠纷不存在");
        return R.ok(dispute);
    }

    /** GET /api/disputes/mine — 我的纠纷 */
    @GetMapping("/mine")
    public R myDisputes(HttpServletRequest request) {
        Long userId = getUserId(request);
        if (userId == null) return R.error(401, "请先登录");
        List<Dispute> list = disputeService.getMyDisputes(userId);
        return R.ok(list);
    }

    /** GET /api/disputes/{id}/vote-stats — 投票统计 */
    @GetMapping("/{id}/vote-stats")
    public R voteStats(@PathVariable Long id) {
        Map<String, Object> stats = disputeService.voteStats(id);
        return R.ok(stats);
    }
}
