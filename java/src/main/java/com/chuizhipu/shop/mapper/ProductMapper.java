package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Product;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductMapper {

    /** 首页推荐 — 按销量倒序 */
    List<Product> selectPopular(@Param("limit") int limit);

    List<Product> selectRecentApproved(@Param("days") int days, @Param("limit") int limit);

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

    /** 待审核商品列表 */
    List<Product> selectPending();

    /** 审核商品 */
    int updateAuditStatus(@Param("id") Long id, @Param("auditStatus") String auditStatus);

    /** 更新商品信息 */
    int update(Product product);

    /** 查商品所属匠人的 user_id */
    Long selectArtisanUserIdByProductId(@Param("productId") Long productId);

    /** 查询用户自己发布的全部未删除作品（包含待审核和已驳回） */
    List<Product> selectByOwnerUserId(@Param("userId") Long userId);

    /** 逻辑删除作品，保留历史订单快照和关联数据 */
    int softDelete(@Param("id") Long id);
}
