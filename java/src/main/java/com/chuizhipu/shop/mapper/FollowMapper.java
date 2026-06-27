package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Follow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FollowMapper {

    int insert(Follow follow);

    int delete(@Param("userId") Long userId, @Param("artisanId") Long artisanId);

    int exists(@Param("userId") Long userId, @Param("artisanId") Long artisanId);

    /** 用户关注总数 */
    int countByUserId(@Param("userId") Long userId);

    /** 用户关注的匠人 id 列表 */
    List<Long> selectArtisanIdsByUserId(@Param("userId") Long userId);
}
