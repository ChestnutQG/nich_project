package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Follow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface FollowMapper {

    int insert(Follow follow);

    int delete(@Param("userId") Long userId, @Param("artisanId") Long artisanId);

    int exists(@Param("userId") Long userId, @Param("artisanId") Long artisanId);
}
