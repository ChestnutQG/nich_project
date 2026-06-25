package com.nonheritage.demo.controller;

import com.nonheritage.demo.dto.ApiResponse;
import com.nonheritage.demo.dto.OrderRequest;
import com.nonheritage.demo.entity.Order;
import com.nonheritage.demo.service.OrderService;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

/** 订单控制器：下单、支付、发货、确认收货、订单查询 */
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    /** 创建订单 @param req 订单请求（含商品ID） @param request HTTP请求 @return 创建的订单 */
    @PostMapping
    public ApiResponse<?> create(@RequestBody OrderRequest req, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        Order o = orderService.create(userId, req.getProductId());
        return ApiResponse.ok(o);
    }

    /** 查询订单详情 @param id 订单ID @return 订单信息 */
    @GetMapping("/{id}")
    public ApiResponse<?> getById(@PathVariable Long id) {
        return ApiResponse.ok(orderService.getById(id));
    }

    /** 支付订单 @param id 订单ID @param request HTTP请求 @return 更新后的订单 */
    @PutMapping("/{id}/pay")
    public ApiResponse<?> pay(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(orderService.pay(id, userId));
    }

    /** 卖家发货 @param id 订单ID @param request HTTP请求 @return 更新后的订单 */
    @PutMapping("/{id}/ship")
    public ApiResponse<?> ship(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(orderService.ship(id, userId));
    }

    /** 确认收货 @param id 订单ID @param request HTTP请求 @return 更新后的订单 */
    @PutMapping("/{id}/confirm")
    public ApiResponse<?> confirm(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(orderService.confirm(id, userId));
    }

    /** 我买到的订单 @param request HTTP请求 @return 买家订单列表 */
    @GetMapping("/bought")
    public ApiResponse<?> bought(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(orderService.bought(userId));
    }

    /** 我卖出的订单 @param request HTTP请求 @return 卖家订单列表 */
    @GetMapping("/sold")
    public ApiResponse<?> sold(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        return ApiResponse.ok(orderService.sold(userId));
    }
}
