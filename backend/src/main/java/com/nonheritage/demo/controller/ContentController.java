package com.nonheritage.demo.controller;

import com.nonheritage.demo.dto.ApiResponse;
import com.nonheritage.demo.dto.ContentRequest;
import com.nonheritage.demo.entity.Content;
import com.nonheritage.demo.service.ContentService;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

/** 内容控制器：非遗内容CRUD、点赞、列表查询 */
@RestController
@RequestMapping("/api/contents")
public class ContentController {
    private final ContentService contentService;

    public ContentController(ContentService contentService) {
        this.contentService = contentService;
    }

    /** 创建非遗内容 @param req 内容请求体 @param request HTTP请求 @return 创建的内容 */
    @PostMapping
    public ApiResponse<?> create(@RequestBody ContentRequest req, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        Content c = contentService.create(userId, req);
        return ApiResponse.ok(c);
    }

    /** 分页查询内容列表 @param page 页码 @param size 每页条数 @param tag 标签筛选 @param sort 排序方式 @return 分页结果 */
    @GetMapping
    public ApiResponse<?> list(@RequestParam(defaultValue = "1") int page,
                               @RequestParam(defaultValue = "10") int size,
                               @RequestParam(required = false) String tag,
                               @RequestParam(defaultValue = "newest") String sort) {
        return ApiResponse.ok(contentService.list(page, size, tag, sort));
    }

    /** 查看内容详情 @param id 内容ID @param request HTTP请求 @return 内容详情含商品列表 */
    @GetMapping("/{id}")
    public ApiResponse<?> detail(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(contentService.detail(id, userId));
    }

    /** 点赞内容 @param id 内容ID @return 空响应 */
    @PutMapping("/{id}/like")
    public ApiResponse<?> like(@PathVariable Long id) {
        contentService.like(id);
        return ApiResponse.ok(null);
    }

    /** 我的内容列表 @param request HTTP请求 @return 当前用户发布的所有内容 */
    @GetMapping("/mine")
    public ApiResponse<?> mine(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(contentService.myContents(userId));
    }
}
