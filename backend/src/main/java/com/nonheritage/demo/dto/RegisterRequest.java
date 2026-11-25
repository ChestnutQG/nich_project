package com.nonheritage.demo.dto;

/** 注册请求DTO */
public class RegisterRequest {
    private String username; // 用户名
    private String password; // 密码
    private String phone;    // 手机号

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}
