package com.chuizhipu.shop;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.Map;

@SpringBootApplication
@MapperScan("com.chuizhipu.shop.mapper")
public class ShopApplication {

    public static void main(String[] args) {
        SpringApplication application = new SpringApplication(ShopApplication.class);
        application.setDefaultProperties(Map.of(
                "mybatis.mapper-locations", "classpath*:mapper/*.xml"
        ));
        application.run(args);
    }
}
