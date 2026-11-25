package com.nonheritage.demo.service;

import com.nonheritage.demo.dto.LoginRequest;
import com.nonheritage.demo.dto.RegisterRequest;
import com.nonheritage.demo.entity.User;
import com.nonheritage.demo.repository.UserRepository;
import com.nonheritage.demo.util.TokenUtil;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/** 用户服务：注册、登录、获取当前用户 */
@Service
public class UserService {
    private final UserRepository userRepository;
    private final TokenUtil tokenUtil;

    public UserService(UserRepository userRepository, TokenUtil tokenUtil) {
        this.userRepository = userRepository;
        this.tokenUtil = tokenUtil;
    }

    /** 注册新用户 @param req 注册请求 @return token与用户信息 */
    public Map<String, Object> register(RegisterRequest req) {
        if (userRepository.findByPhone(req.getPhone()) != null)
            throw new IllegalArgumentException("手机号已注册");
        if (userRepository.findByUsername(req.getUsername()) != null)
            throw new IllegalArgumentException("用户名已存在");

        User user = new User();
        user.setUsername(req.getUsername());
        user.setPassword(req.getPassword());
        user.setPhone(req.getPhone());
        user.setRole("user");
        user.setCreditScore(100);
        user.setStatus("active");
        user = userRepository.save(user);

        String token = tokenUtil.createToken(user.getId());
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("userId", user.getId());
        result.put("username", user.getUsername());
        result.put("role", user.getRole());
        return result;
    }

    /** 用户登录 @param req 登录请求 @return token与用户信息 */
    public Map<String, Object> login(LoginRequest req) {
        User user = userRepository.findByPhone(req.getPhone());
        if (user == null) throw new IllegalArgumentException("手机号未注册");
        if (!user.getPassword().equals(req.getPassword()))
            throw new IllegalArgumentException("密码错误");
        if ("frozen".equals(user.getStatus()))
            throw new IllegalArgumentException("账号已被冻结");

        String token = tokenUtil.createToken(user.getId());
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("userId", user.getId());
        result.put("username", user.getUsername());
        result.put("role", user.getRole());
        result.put("avatarUrl", user.getAvatarUrl());
        return result;
    }

    /** 获取当前登录用户 @param userId 用户ID @return 用户实体 */
    public User getCurrentUser(Long userId) {
        return userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("用户不存在"));
    }
}
