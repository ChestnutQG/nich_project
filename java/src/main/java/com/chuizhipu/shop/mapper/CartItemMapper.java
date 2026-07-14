package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.CartItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CartItemMapper {

    List<CartItem> selectByUserId(@Param("userId") Long userId);

    CartItem selectByUserAndSku(@Param("userId") Long userId, @Param("skuId") Long skuId);

    int insert(CartItem item);

    int updateQuantity(@Param("id") Long id, @Param("quantity") Integer quantity);

    int updateChecked(@Param("id") Long id, @Param("isChecked") Integer isChecked);

    int updateAllChecked(@Param("userId") Long userId, @Param("isChecked") Integer isChecked);

    int deleteById(@Param("id") Long id);

    int deleteByUserId(@Param("userId") Long userId);

    int countByUserId(@Param("userId") Long userId);
}
