package com.chuizhipu.shop.service;

import com.chuizhipu.shop.common.EntityUtils;
import com.chuizhipu.shop.entity.Order;
import com.chuizhipu.shop.entity.OrderItem;
import com.chuizhipu.shop.mapper.OrderItemMapper;
import com.chuizhipu.shop.mapper.OrderMapper;
import com.chuizhipu.shop.vo.AddressVO;
import com.chuizhipu.shop.vo.OrderItemVO;
import com.chuizhipu.shop.vo.OrderVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class OrderService {

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;

    public OrderService(OrderMapper orderMapper, OrderItemMapper orderItemMapper) {
        this.orderMapper = orderMapper;
        this.orderItemMapper = orderItemMapper;
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
        orderMapper.insert(order);
        Long orderId = order.getId();
        items.forEach(item -> item.setOrderId(orderId));
        orderItemMapper.insertBatch(items);
        return orderId;
    }

    /** 更新订单状态 */
    public void updateStatus(Long orderId, int status) {
        orderMapper.updateStatus(orderId, status);
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
