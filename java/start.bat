@echo off
chcp 65001 >nul
echo ========================================
echo   锤子铺 Spring Boot 后端启动
echo ========================================
echo.

cd /d E:\demo\chuizhiShop\java

echo [1/2] 正在编译打包...
call mvn clean package -DskipTests -q
if %ERRORLEVEL% NEQ 0 (
    echo 编译失败，请检查错误信息
    pause
    exit /b 1
)

echo [2/2] 正在启动服务...
echo.
echo 接口地址: http://localhost:8080/api
echo 按 Ctrl+C 停止服务
echo ========================================
echo.

java -jar target\chuizhi-shop-1.0.0.jar

pause
