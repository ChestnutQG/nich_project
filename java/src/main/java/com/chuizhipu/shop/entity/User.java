package com.chuizhipu.shop.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户
 */
public class User {
    private Long id;
    private String nickname;
    private String avatar;
    private String phone;
    private String password;
    private Integer collectCount;
    private Integer followCount;
    private Integer orderCount;
    private LocalDateTime createTime;
    private String role;
    private Integer creditScore;
    private String status;
    private LocalDateTime updateTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public Integer getCollectCount() { return collectCount; }
    public void setCollectCount(Integer collectCount) { this.collectCount = collectCount; }
    public Integer getFollowCount() { return followCount; }
    public void setFollowCount(Integer followCount) { this.followCount = followCount; }
    public Integer getOrderCount() { return orderCount; }
    public void setOrderCount(Integer orderCount) { this.orderCount = orderCount; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public Integer getCreditScore() { return creditScore; }
    public void setCreditScore(Integer creditScore) { this.creditScore = creditScore; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
