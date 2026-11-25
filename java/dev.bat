@echo off
chcp 65001 >nul
echo ========================================
echo   锤子铺 Spring Boot 后端启动 [开发模式]
echo ========================================
echo.
echo 接口地址: http://localhost:8080/api
echo 按 Ctrl+C 停止服务
echo ========================================
echo.

cd /d E:\demo\chuizhiShop\java
mvn spring-boot:run

pause
