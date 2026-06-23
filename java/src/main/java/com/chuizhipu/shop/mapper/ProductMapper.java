package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Product;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductMapper {

    /** 首页推荐 — 按销量倒序 */
    List<Product> selectRecommend();

    /** 分页列表 */
    List<Product> selectPage(@Param("categoryId") Long categoryId,
                             @Param("sortBy") String sortBy,
                             @Param("offset") int offset,
                             @Param("size") int size);

    /** 分页计数 */
    long countPage(@Param("categoryId") Long categoryId);

    /** 根据 ID 查商品 */
    Product selectById(@Param("id") Long id);

    /** 搜索 */
    List<Product> search(@Param("keyword") String keyword,
                         @Param("offset") int offset,
                         @Param("size") int size);

    /** 搜索计数 */
    long countSearch(@Param("keyword") String keyword);

    /** 根据匠人查商品 */
    List<Product> selectByArtisanId(@Param("artisanId") Long artisanId);

    /** 发布商品 */
    int insert(Product product);
}
