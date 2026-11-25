package com.nonheritage.demo.controller;

import com.nonheritage.demo.dto.ApiResponse;
import com.nonheritage.demo.dto.LoginRequest;
import com.nonheritage.demo.dto.RegisterRequest;
import com.nonheritage.demo.entity.User;
import com.nonheritage.demo.service.UserService;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

/** 用户控制器：注册、登录、当前用户信息 */
@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /** 用户注册 @param req 注册请求（用户名/密码/手机号） @return 用户信息与token */
    @PostMapping("/register")
    public ApiResponse<?> register(@RequestBody RegisterRequest req) {
        return ApiResponse.ok(userService.register(req));
    }

    /** 用户登录 @param req 登录请求（手机号/密码） @return 用户信息与token */
    @PostMapping("/login")
    public ApiResponse<?> login(@RequestBody LoginRequest req) {
        return ApiResponse.ok(userService.login(req));
    }

    /** 获取当前登录用户信息 @param request HTTP请求（含token解析出的userId） @return 用户详情 */
    @GetMapping("/me")
    public ApiResponse<?> me(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        User user = userService.getCurrentUser(userId);
        return ApiResponse.ok(user);
    }
}
