package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Favorite;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FavoriteMapper {

    /** 查用户收藏的商品 ID 列表 */
    List<Long> selectProductIdsByUserId(@Param("userId") Long userId,
                                         @Param("productIds") List<Long> productIds);

    int insert(Favorite favorite);

    int delete(@Param("userId") Long userId, @Param("productId") Long productId);

    /** 是否已收藏 */
    int exists(@Param("userId") Long userId, @Param("productId") Long productId);

    /** 用户收藏总数 */
    int countByUserId(@Param("userId") Long userId);
}
