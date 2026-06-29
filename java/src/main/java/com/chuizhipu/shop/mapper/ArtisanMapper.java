package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Artisan;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ArtisanMapper {

    /** 匠人列表（可按技艺筛选） */
    List<Artisan> selectList(@Param("craftType") String craftType,
                             @Param("offset") int offset,
                             @Param("size") int size);

    long countList(@Param("craftType") String craftType);

    /** 热门推荐（按关注数） */
    List<Artisan> selectTop(@Param("limit") int limit);

    /** 匠人详情 */
    Artisan selectById(@Param("id") Long id);

    /** 按关联用户查匠人档案 */
    Artisan selectByUserId(@Param("userId") Long userId);

    /** 新增匠人档案（自动回填 id） */
    int insert(Artisan artisan);

    /** 关注数增减（delta 为 +1 / -1） */
    int incrFollowers(@Param("id") Long id, @Param("delta") int delta);

    /** 按名称/技艺搜索匠人 */
    List<Artisan> selectByName(@Param("keyword") String keyword,
                                @Param("offset") int offset,
                                @Param("limit") int limit);

    long countByName(@Param("keyword") String keyword);
}
