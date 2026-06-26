package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.User;
import com.chuizhipu.shop.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import java.nio.charset.StandardCharsets;

@Service
public class UserService {

    private final UserMapper userMapper;

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public User getById(Long id) {
        return userMapper.selectById(id);
    }

    public User getByPhone(String phone) {
        return userMapper.selectByPhone(phone);
    }

    /** 注册 — 密码 MD5 哈希 */
    public Long register(User user) {
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(DigestUtils.md5DigestAsHex(user.getPassword().getBytes(StandardCharsets.UTF_8)));
        }
        if (user.getRole() == null) user.setRole("user");
        if (user.getCreditScore() == null) user.setCreditScore(100);
        if (user.getStatus() == null) user.setStatus("active");
        userMapper.insert(user);
        return user.getId();
    }

    /** 登录验证 — 返回用户或 null */
    public User login(String phone, String password) {
        User user = userMapper.selectByPhone(phone);
        if (user == null) return null;
        if ("frozen".equals(user.getStatus())) return null;
        String hashed = DigestUtils.md5DigestAsHex(password.getBytes(StandardCharsets.UTF_8));
        if (!hashed.equals(user.getPassword())) return null;
        return user;
    }

    /** 手机号一键登录/注册（无密码） */
    public User phoneLogin(String phone) {
        User user = userMapper.selectByPhone(phone);
        if (user == null) {
            user = new User();
            user.setPhone(phone);
            user.setNickname("非遗爱好者");
            user.setRole("user");
            user.setCreditScore(100);
            user.setStatus("active");
            userMapper.insert(user);
        }
        return user;
    }

    public void updateProfile(User user) {
        userMapper.updateById(user);
    }
}
