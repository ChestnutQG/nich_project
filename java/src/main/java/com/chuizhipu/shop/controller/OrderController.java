package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.Order;
import com.chuizhipu.shop.entity.OrderItem;
import com.chuizhipu.shop.service.OrderService;
import com.chuizhipu.shop.vo.OrderVO;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    /** GET /api/orders — 用户订单列表（需登录） */
    @GetMapping
    public R list(HttpServletRequest request,
                  @RequestParam(required = false) Integer status) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        List<OrderVO> orders = orderService.getOrders(userId, status);
        return R.ok(orders);
    }

    /** GET /api/orders/{id} — 订单详情 */
    @GetMapping("/{id}")
    public R detail(@PathVariable Long id) {
        OrderVO order = orderService.getOrderDetail(id);
        if (order == null) {
            return R.error("订单不存在");
        }
        return R.ok(order);
    }

    /** POST /api/orders — 创建订单（需登录） */
    @PostMapping
    public R create(HttpServletRequest request, @RequestBody OrderCreateReq req) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        Order order = req.getOrder();
        order.setUserId(userId);
        List<OrderItem> items = req.getItems();
        if (order == null || items == null || items.isEmpty()) {
            return R.error("订单信息不完整");
        }
        Long orderId = orderService.createOrder(order, items);
        return R.ok(orderId);
    }

    /** PUT /api/orders/{id}/status — 更新订单状态 */
    @PutMapping("/{id}/status")
    public R updateStatus(@PathVariable Long id,
                          @RequestBody StatusUpdateReq req) {
        orderService.updateStatus(id, req.getStatus());
        return R.ok(null);
    }

    // 用于接收请求体的简单包装类
    public static class OrderCreateReq {
        private Order order;
        private List<OrderItem> items;

        public Order getOrder() { return order; }
        public void setOrder(Order order) { this.order = order; }
        public List<OrderItem> getItems() { return items; }
        public void setItems(List<OrderItem> items) { this.items = items; }
    }

    public static class StatusUpdateReq {
        private Integer status;

        public Integer getStatus() { return status; }
        public void setStatus(Integer status) { this.status = status; }
    }
}
