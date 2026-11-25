package com.nonheritage.demo.service;

import com.nonheritage.demo.entity.Order;
import com.nonheritage.demo.entity.Product;
import com.nonheritage.demo.repository.OrderRepository;
import com.nonheritage.demo.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** 订单服务：下单、支付、发货、确认收货、订单查询 */
@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;

    public OrderService(OrderRepository orderRepository, ProductRepository productRepository) {
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
    }

    /** 创建订单并扣减库存 @param buyerId 买家ID @param productId 商品ID @return 创建的订单 */
    @Transactional
    public Order create(Long buyerId, Long productId) {
        Product p = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("商品不存在"));
        if (p.getStock() <= 0) throw new IllegalArgumentException("库存不足");
        if (p.getSellerId().equals(buyerId)) throw new IllegalArgumentException("不能购买自己的商品");

        p.setStock(p.getStock() - 1);
        productRepository.save(p);

        Order o = new Order();
        o.setBuyerId(buyerId);
        o.setSellerId(p.getSellerId());
        o.setProductId(productId);
        o.setAmount(p.getPrice());
        o.setStatus("pending");
        o.setAfterSaleStatus("none");
        return orderRepository.save(o);
    }

    /** 支付订单 @param orderId 订单ID @param userId 当前用户ID @return 更新后的订单 */
    public Order pay(Long orderId, Long userId) {
        Order o = getAndCheck(orderId, userId, true);
        if (!"pending".equals(o.getStatus())) throw new IllegalArgumentException("订单状态不正确");
        o.setStatus("paid");
        return orderRepository.save(o);
    }

    /** 卖家发货，生成物流单号 @param orderId 订单ID @param userId 卖家ID @return 更新后的订单 */
    public Order ship(Long orderId, Long userId) {
        Order o = getAndCheck(orderId, userId, false);
        if (!"paid".equals(o.getStatus())) throw new IllegalArgumentException("订单状态不正确");
        o.setStatus("shipped");
        o.setLogisticsNo("SF" + System.currentTimeMillis());
        return orderRepository.save(o);
    }

    /** 确认收货 @param orderId 订单ID @param userId 买家ID @return 更新后的订单 */
    public Order confirm(Long orderId, Long userId) {
        Order o = getAndCheck(orderId, userId, true);
        if (!"shipped".equals(o.getStatus())) throw new IllegalArgumentException("订单状态不正确");
        o.setStatus("received");
        o.setAfterSaleStatus("none");
        return orderRepository.save(o);
    }

    /** 查询订单详情 @param orderId 订单ID @return 订单 */
    public Order getById(Long orderId) {
        return orderRepository.findById(orderId).orElseThrow(() -> new IllegalArgumentException("订单不存在"));
    }

    /** 我买到的订单 @param userId 买家ID @return 订单列表 */
    public List<Order> bought(Long userId) {
        return orderRepository.findByBuyerIdOrderByCreatedAtDesc(userId);
    }

    /** 我卖出的订单 @param userId 卖家ID @return 订单列表 */
    public List<Order> sold(Long userId) {
        return orderRepository.findBySellerIdOrderByCreatedAtDesc(userId);
    }

    /** 获取订单并校验操作权限 @param orderId 订单ID @param userId 用户ID @param isBuyer 是否买家身份 @return 订单 */
    private Order getAndCheck(Long orderId, Long userId, boolean isBuyer) {
        Order o = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在"));
        Long expected = isBuyer ? o.getBuyerId() : o.getSellerId();
        if (!expected.equals(userId)) throw new IllegalArgumentException("无权操作此订单");
        return o;
    }
}
