package com.nonheritage.demo.dto;

/** 登录请求DTO */
public class LoginRequest {
    private String phone;    // 手机号
    private String password; // 密码

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
