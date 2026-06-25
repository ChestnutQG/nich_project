package com.nonheritage.demo.repository;

import com.nonheritage.demo.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/** 订单数据访问层 */
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByBuyerIdOrderByCreatedAtDesc(Long buyerId);   // 按买家ID查询，时间倒序
    List<Order> findBySellerIdOrderByCreatedAtDesc(Long sellerId); // 按卖家ID查询，时间倒序
}
