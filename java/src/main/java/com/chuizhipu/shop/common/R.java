package com.chuizhipu.shop.common;

import java.util.HashMap;
import java.util.Map;

/**
 * 统一 API 响应 — 匹配前端 ApiResponse<T> 结构
 */
public class R {

    private int code;
    private String message;
    private Object data;

    private R(int code, String message, Object data) {
        this.code = code;
        this.message = message;
        this.data = data;
    }

    public static R ok(Object data) {
        return new R(0, "ok", data);
    }

    public static R ok() {
        return new R(0, "ok", null);
    }

    public static R error(String message) {
        return new R(-1, message, null);
    }

    public static R error(int code, String message) {
        return new R(code, message, null);
    }

    // ---- 懒得分 VO 时直接用 Map 拼分页 ----
    public static Map<String, Object> pageData(java.util.List<?> list, long total, int page, int pageSize) {
        Map<String, Object> data = new HashMap<>();
        data.put("list", list);
        data.put("total", total);
        data.put("page", page);
        data.put("pageSize", pageSize);
        return data;
    }

    public int getCode() { return code; }
    public void setCode(int code) { this.code = code; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Object getData() { return data; }
    public void setData(Object data) { this.data = data; }
}
