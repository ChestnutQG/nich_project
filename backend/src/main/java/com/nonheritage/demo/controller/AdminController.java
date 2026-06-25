package com.nonheritage.demo.controller;

import com.nonheritage.demo.dto.ApiResponse;
import com.nonheritage.demo.dto.RejectRequest;
import com.nonheritage.demo.service.AdminService;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

/** 管理员控制器：内容审核列表、通过、驳回 */
@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    /** 获取审核列表 @param status 审核状态（默认reviewing） @param request HTTP请求 @return 内容列表 */
    @GetMapping("/audit/list")
    public ApiResponse<?> auditList(@RequestParam(defaultValue = "reviewing") String status,
                                     HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        adminService.checkAdmin(userId);
        return ApiResponse.ok(adminService.auditList(status));
    }

    /** 审核通过 @param id 内容ID @param request HTTP请求 @return 空响应 */
    @PutMapping("/audit/{id}/pass")
    public ApiResponse<?> pass(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        adminService.checkAdmin(userId);
        adminService.pass(id, userId);
        return ApiResponse.ok(null);
    }

    /** 审核驳回 @param id 内容ID @param req 驳回请求（含原因） @param request HTTP请求 @return 空响应 */
    @PutMapping("/audit/{id}/reject")
    public ApiResponse<?> reject(@PathVariable Long id, @RequestBody RejectRequest req,
                                  HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        adminService.checkAdmin(userId);
        adminService.reject(id, userId, req.getReason());
        return ApiResponse.ok(null);
    }
}
