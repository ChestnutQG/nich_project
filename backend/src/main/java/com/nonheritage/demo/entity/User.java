package com.nonheritage.demo.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

/** 用户实体类 */
@Entity
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;               // 主键
    private String username;       // 用户名
    private String password;       // 密码（BCrypt加密）
    private String phone;          // 手机号（登录账号）
    private String avatarUrl;      // 头像URL
    private String role = "user";  // 角色：user / admin
    private Integer creditScore = 100; // 信用分，默认100，低于60失去陪审资格
    private String status = "active";  // 状态：active / banned
    private LocalDateTime createdAt = LocalDateTime.now(); // 注册时间

    public User() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public Integer getCreditScore() { return creditScore; }
    public void setCreditScore(Integer creditScore) { this.creditScore = creditScore; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
