package com.chuizhipu.shop.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.File;

/**
 * 静态资源配置 — 让上传的图片可以通过 URL 直接访问
 */
@Configuration
public class WebResourceConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 上传目录 — 与 FileController 保持一致，使用项目根目录绝对路径
        String uploadPath = System.getProperty("user.dir") + File.separator + "uploads";
        // /uploads/xxx.jpg → 映射到本地的 uploads/ 目录
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + uploadPath + File.separator);
    }
}
