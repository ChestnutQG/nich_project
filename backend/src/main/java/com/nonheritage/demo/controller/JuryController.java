package com.nonheritage.demo.controller;

import com.nonheritage.demo.dto.ApiResponse;
import com.nonheritage.demo.dto.VoteRequest;
import com.nonheritage.demo.service.DisputeService;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

/** 陪审团控制器：陪审邀请查询、投票 */
@RestController
@RequestMapping("/api/jury")
public class JuryController {
    private final DisputeService disputeService;

    public JuryController(DisputeService disputeService) {
        this.disputeService = disputeService;
    }

    /** 我的陪审邀请 @param request HTTP请求 @return 陪审邀请列表 */
    @GetMapping("/invitations/mine")
    public ApiResponse<?> myInvitations(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(disputeService.myInvitations(userId));
    }

    /** 陪审投票 @param req 投票请求（含纠纷ID/投票方） @param request HTTP请求 @return 空响应 */
    @PostMapping("/votes")
    public ApiResponse<?> vote(@RequestBody VoteRequest req, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        disputeService.vote(userId, req);
        return ApiResponse.ok(null);
    }
}
