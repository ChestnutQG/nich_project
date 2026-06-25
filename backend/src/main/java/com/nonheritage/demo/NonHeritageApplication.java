package com.nonheritage.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/** 国风非遗App后端启动类，启用SpringBoot自动配置与定时任务 */
@SpringBootApplication
@EnableScheduling
public class NonHeritageApplication {
    /** 应用入口 @param args 命令行参数 */
    public static void main(String[] args) {
        SpringApplication.run(NonHeritageApplication.class, args);
    }
}
