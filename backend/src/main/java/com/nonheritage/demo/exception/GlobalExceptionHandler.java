package com.nonheritage.demo.exception;

import com.nonheritage.demo.dto.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/** 全局异常处理器：统一拦截业务异常，返回规范ApiResponse */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /** 处理参数/业务校验异常，返回400 @param e 异常 @return 失败响应 */
    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiResponse<?> handleBadRequest(IllegalArgumentException e) {
        return ApiResponse.fail(400, e.getMessage());
    }

    /** 处理运行时异常，返回500 @param e 异常 @return 失败响应 */
    @ExceptionHandler(RuntimeException.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiResponse<?> handleRuntime(RuntimeException e) {
        return ApiResponse.fail(500, e.getMessage());
    }

    /** 兜底处理其他异常，返回500，不泄露内部错误 @param e 异常 @return 失败响应 */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiResponse<?> handleOther(Exception e) {
        return ApiResponse.fail(500, "服务器内部错误");
    }
}
