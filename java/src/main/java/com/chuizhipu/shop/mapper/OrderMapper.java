package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Order;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface OrderMapper {

    /** 用户订单总数 */
    int countByUserId(@Param("userId") Long userId);

    Order selectById(@Param("id") Long id);

    /** 用户订单列表 */
    List<Order> selectByUserId(@Param("userId") Long userId,
                               @Param("status") Integer status);

    int insert(Order order);

    int updateStatus(@Param("id") Long id, @Param("status") Integer status);
}
