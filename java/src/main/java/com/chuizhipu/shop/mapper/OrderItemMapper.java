package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.OrderItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface OrderItemMapper {

    /** 根据订单 ID 查所有订单项 */
    List<OrderItem> selectByOrderId(@Param("orderId") Long orderId);

    /** 根据多个订单 ID 批量查 */
    List<OrderItem> selectByOrderIds(@Param("orderIds") List<Long> orderIds);

    int insert(OrderItem item);

    int insertBatch(@Param("items") List<OrderItem> items);
}
