package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 健康检查 — 供前端自动探测服务器地址
 */
@RestController
public class HealthController {

    @GetMapping("/api/ping")
    public R ping() {
        return R.ok("pong");
    }
}
