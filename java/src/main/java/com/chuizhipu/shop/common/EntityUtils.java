package com.chuizhipu.shop.common;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * 实体 → VO 转换工具
 */
public class EntityUtils {

    private static final ObjectMapper MAPPER = new ObjectMapper();
    private static final ZoneId ZONE = ZoneId.of("Asia/Shanghai");

    /** Long ID → String */
    public static String strId(Long id) {
        return id != null ? id.toString() : "";
    }

    /** LocalDateTime → 毫秒时间戳 */
    public static Long toEpoch(LocalDateTime dt) {
        if (dt == null) return null;
        return dt.atZone(ZONE).toInstant().toEpochMilli();
    }

    /** 解析 JSON 字符串为 List<String>（用于 images, certificateImages） */
    public static List<String> parseStrList(String json) {
        if (json == null || json.isBlank()) return Collections.emptyList();
        try {
            return MAPPER.readValue(json, new TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            return Collections.emptyList();
        }
    }

    /** 解析 JSON 字符串为 List<CraftStepVO>（用于 craftProcess） */
    public static <T> T parseJson(String json, Class<T> clazz) {
        if (json == null || json.isBlank()) return null;
        try {
            return MAPPER.readValue(json, clazz);
        } catch (JsonProcessingException e) {
            return null;
        }
    }

    /** 解析 JSON 字符串为 List<T> */
    public static <T> List<T> parseJsonList(String json, Class<T> elementClass) {
        if (json == null || json.isBlank()) return Collections.emptyList();
        try {
            return MAPPER.readValue(json,
                    MAPPER.getTypeFactory().constructCollectionType(List.class, elementClass));
        } catch (JsonProcessingException e) {
            return Collections.emptyList();
        }
    }

    /** 逗号分隔字符串 → List */
    public static List<String> parseTags(String tags) {
        if (tags == null || tags.isBlank()) return Collections.emptyList();
        return Arrays.asList(tags.split(","));
    }

    /** 对象 → JSON 字符串 */
    public static String toJson(Object obj) {
        try {
            return MAPPER.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            return "{}";
        }
    }
}
