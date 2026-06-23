package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {

    User selectById(@Param("id") Long id);

    User selectByPhone(@Param("phone") String phone);

    int insert(User user);

    int updateById(User user);
}
