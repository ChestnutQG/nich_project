package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.User;
import com.chuizhipu.shop.mapper.UserMapper;
import org.springframework.stereotype.Service;

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

    public Long register(User user) {
        userMapper.insert(user);
        return user.getId();
    }

    public void updateProfile(User user) {
        userMapper.updateById(user);
    }
}
