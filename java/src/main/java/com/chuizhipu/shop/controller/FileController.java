package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 文件上传接口
 */
@RestController
@RequestMapping("/api")
public class FileController {

    // 使用项目根目录下的绝对路径，避免 Tomcat 临时工作目录的问题
    private static final String UPLOAD_DIR = System.getProperty("user.dir") + File.separator + "uploads";

    /** POST /api/upload — 上传图片（支持多文件） */
    @PostMapping("/upload")
    public R upload(@RequestParam("files") MultipartFile[] files,
                    HttpServletRequest request) {
        if (files == null || files.length == 0) {
            return R.error("请选择文件");
        }

        // 按日期分目录: uploads/2026-06-23/
        String today = LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE);
        File dir = new File(UPLOAD_DIR, today);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        // 构建基础 URL: http://10.73.187.13:8080
        String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort();

        List<String> urls = new ArrayList<>();
        for (MultipartFile file : files) {
            if (file.isEmpty()) continue;

            String originalName = file.getOriginalFilename();
            String ext = "";
            if (originalName != null && originalName.contains(".")) {
                ext = originalName.substring(originalName.lastIndexOf("."));
            }
            String newName = UUID.randomUUID().toString().replace("-", "") + ext;

            File dest = new File(dir, newName);
            try {
                file.transferTo(dest);
                urls.add(baseUrl + "/uploads/" + today + "/" + newName);
            } catch (IOException e) {
                return R.error("上传失败: " + e.getMessage());
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("urls", urls);
        return R.ok(result);
    }
}
