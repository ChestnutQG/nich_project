package com.chuizhipu.shop.service;

import com.chuizhipu.shop.common.EntityUtils;
import com.chuizhipu.shop.entity.Order;
import com.chuizhipu.shop.entity.OrderItem;
import com.chuizhipu.shop.mapper.OrderItemMapper;
import com.chuizhipu.shop.mapper.OrderMapper;
import com.chuizhipu.shop.mapper.ProductMapper;
import com.chuizhipu.shop.vo.AddressVO;
import com.chuizhipu.shop.vo.OrderItemVO;
import com.chuizhipu.shop.vo.OrderVO;
import com.chuizhipu.shop.websocket.ChatWebSocketHandler;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class OrderService {

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final ProductMapper productMapper;
    private final MessageService messageService;
    private final ChatWebSocketHandler chatHandler;

    public OrderService(OrderMapper orderMapper, OrderItemMapper orderItemMapper,
                       ProductMapper productMapper, MessageService messageService,
                       ChatWebSocketHandler chatHandler) {
        this.orderMapper = orderMapper;
        this.orderItemMapper = orderItemMapper;
        this.productMapper = productMapper;
        this.messageService = messageService;
        this.chatHandler = chatHandler;
    }

    /** 用户订单列表 */
    public List<OrderVO> getOrders(Long userId, Integer status) {
        List<Order> orders = orderMapper.selectByUserId(userId, status);
        return toVOList(orders);
    }

    /** 订单详情 */
    public OrderVO getOrderDetail(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) return null;
        return toVO(order);
    }

    /** 创建订单 */
    @Transactional
    public Long createOrder(Order order, List<OrderItem> items) {
        // 自动生成订单号：时间戳 + 4位随机数
        String orderNo = java.time.LocalDateTime.now()
                .format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", (int)(Math.random() * 10000));
        order.setOrderNo(orderNo);
        orderMapper.insert(order);
        Long orderId = order.getId();
        items.forEach(item -> item.setOrderId(orderId));
        orderItemMapper.insertBatch(items);
        return orderId;
    }

    /** 更新订单状态 */
    @Transactional
    public void updateStatus(Long orderId, int status) {
        orderMapper.updateStatus(orderId, status);

        // 发送订单状态变更通知
        try {
            Order order = orderMapper.selectById(orderId);
            if (order != null) {
                sendOrderStatusNotification(order, status);
            }
        } catch (Exception e) {
            // 通知失败不影响主流程
        }
    }

    /** 根据订单状态发送通知 */
    private void sendOrderStatusNotification(Order order, int newStatus) {
        String orderNo = order.getOrderNo();
        Long buyerId = order.getUserId();
        Long sellerUserId = getSellerUserId(order.getId());

        switch (newStatus) {
            case 1: // 待发货 → 通知卖家有新的待发货订单
                sendNotif(buyerId, "您的订单 " + orderNo + " 已支付成功，等待卖家发货", "order_status", order.getId());
                if (sellerUserId != null) {
                    sendNotif(sellerUserId, "您有一个新订单 " + orderNo + " 需要发货", "order_status", order.getId());
                }
                break;
            case 2: // 待收货 → 通知买家已发货
                sendNotif(buyerId, "您的订单 " + orderNo + " 已发货，请注意查收", "order_status", order.getId());
                break;
            case 3: // 已完成 → 通知双方
                sendNotif(buyerId, "您的订单 " + orderNo + " 已完成，感谢您的购买", "order_status", order.getId());
                if (sellerUserId != null) {
                    sendNotif(sellerUserId, "订单 " + orderNo + " 已确认完成", "order_status", order.getId());
                }
                break;
            case 4: // 退款中（维权触发，已在 DisputeService 通知，此处不重复）
                break;
            case 5: // 已取消 → 通知双方
                sendNotif(buyerId, "您的订单 " + orderNo + " 已取消", "order_status", order.getId());
                if (sellerUserId != null) {
                    sendNotif(sellerUserId, "订单 " + orderNo + " 已取消", "order_status", order.getId());
                }
                break;
        }
    }

    /** 通过订单获取卖家用户ID */
    private Long getSellerUserId(Long orderId) {
        try {
            List<OrderItem> items = orderItemMapper.selectByOrderId(orderId);
            if (items != null && !items.isEmpty()) {
                Long productId = items.get(0).getProductId();
                if (productId != null) {
                    return productMapper.selectArtisanUserIdByProductId(productId);
                }
            }
        } catch (Exception e) {
            // ignore
        }
        return null;
    }

    private void sendNotif(Long userId, String content, String type, Long relatedId) {
        try {
            messageService.sendNotification(userId, content, type, relatedId);
            wsPush(userId, type, content, relatedId);
        } catch (Exception e) {
            // ignore
        }
    }

    private void wsPush(Long userId, String type, String content, Long relatedId) {
        try {
            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("type", "notification");
            payload.put("notificationType", type);
            payload.put("content", content);
            payload.put("relatedId", relatedId);
            chatHandler.pushToUser(userId, payload);
        } catch (Exception e) {
            // ignore
        }
    }

    // ---- Entity → VO ----

    private List<OrderVO> toVOList(List<Order> orders) {
        if (orders.isEmpty()) return Collections.emptyList();

        // 批量查订单项
        List<Long> orderIds = orders.stream().map(Order::getId).collect(Collectors.toList());
        List<OrderItem> allItems = orderItemMapper.selectByOrderIds(orderIds);
        Map<Long, List<OrderItem>> itemMap = allItems.stream()
                .collect(Collectors.groupingBy(OrderItem::getOrderId));

        return orders.stream()
                .map(o -> entityToVO(o, itemMap.getOrDefault(o.getId(), Collections.emptyList())))
                .collect(Collectors.toList());
    }

    private OrderVO toVO(Order order) {
        List<OrderItem> items = orderItemMapper.selectByOrderId(order.getId());
        return entityToVO(order, items);
    }

    private OrderVO entityToVO(Order o, List<OrderItem> items) {
        OrderVO vo = new OrderVO();
        vo.setId(EntityUtils.strId(o.getId()));
        vo.setOrderNo(o.getOrderNo());
        vo.setStatus(o.getStatus());
        vo.setTotalAmount(o.getTotalAmount());
        vo.setDiscountAmount(o.getDiscountAmount());
        vo.setFreight(o.getFreight());
        vo.setPayAmount(o.getPayAmount());
        vo.setCreateTime(EntityUtils.toEpoch(o.getCreateTime()));
        vo.setPayTime(EntityUtils.toEpoch(o.getPayTime()));
        vo.setDeliverTime(EntityUtils.toEpoch(o.getDeliverTime()));
        vo.setFinishTime(EntityUtils.toEpoch(o.getFinishTime()));

        // 解析地址 JSON
        vo.setAddress(EntityUtils.parseJson(o.getAddressJson(), AddressVO.class));

        // 转换订单项
        vo.setItems(items.stream().map(this::itemToVO).collect(Collectors.toList()));

        return vo;
    }

    private OrderItemVO itemToVO(OrderItem i) {
        OrderItemVO vo = new OrderItemVO();
        vo.setProductId(EntityUtils.strId(i.getProductId()));
        vo.setProductName(i.getProductName());
        vo.setProductImage(i.getProductImage());
        vo.setSkuId(EntityUtils.strId(i.getSkuId()));
        vo.setSkuName(i.getSkuName());
        vo.setPrice(i.getPrice());
        vo.setQuantity(i.getQuantity());
        return vo;
    }
}
