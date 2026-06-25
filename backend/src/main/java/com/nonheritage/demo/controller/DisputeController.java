package com.nonheritage.demo.controller;

import com.nonheritage.demo.dto.ApiResponse;
import com.nonheritage.demo.dto.DisputeRequest;
import com.nonheritage.demo.entity.Dispute;
import com.nonheritage.demo.service.DisputeService;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

/** 纠纷控制器：发起纠纷、申请陪审、查看投票、我的纠纷 */
@RestController
@RequestMapping("/api/disputes")
public class DisputeController {
    private final DisputeService disputeService;

    public DisputeController(DisputeService disputeService) {
        this.disputeService = disputeService;
    }

    /** 发起纠纷 @param req 纠纷请求（含订单ID/原因/证据） @param request HTTP请求 @return 创建的纠纷 */
    @PostMapping
    public ApiResponse<?> create(@RequestBody DisputeRequest req, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        Dispute d = disputeService.create(userId, req);
        return ApiResponse.ok(d);
    }

    /** 查询纠纷详情 @param id 纠纷ID @return 纠纷信息 */
    @GetMapping("/{id}")
    public ApiResponse<?> getById(@PathVariable Long id) {
        return ApiResponse.ok(disputeService.getById(id));
    }

    /** 申请陪审团介入 @param id 纠纷ID @param request HTTP请求 @return 更新后的纠纷 */
    @PutMapping("/{id}/request-jury")
    public ApiResponse<?> requestJury(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(disputeService.requestJury(id, userId));
    }

    /** 查看投票统计 @param id 纠纷ID @return 投票统计（总票数/支持买家/支持卖家） */
    @GetMapping("/{id}/vote-stats")
    public ApiResponse<?> voteStats(@PathVariable Long id) {
        return ApiResponse.ok(disputeService.voteStats(id));
    }

    /** 我的纠纷列表 @param request HTTP请求 @return 当前用户相关的纠纷 */
    @GetMapping("/mine")
    public ApiResponse<?> mine(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(disputeService.myDisputes(userId));
    }
}
