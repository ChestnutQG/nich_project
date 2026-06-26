package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.ProductSku;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductSkuMapper {

    /** 根据商品 ID 查所有 SKU */
    List<ProductSku> selectByProductId(@Param("productId") Long productId);

    /** 批量查 SKU（根据多个商品 ID） */
    List<ProductSku> selectByProductIds(@Param("productIds") List<Long> productIds);

    /** 批量插入 SKU */
    int insertBatch(@Param("skus") List<ProductSku> skus);

    ProductSku selectById(Long skuId);
}
