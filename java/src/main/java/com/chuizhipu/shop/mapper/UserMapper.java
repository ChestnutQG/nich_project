package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper {

    User selectById(@Param("id") Long id);

    User selectByPhone(@Param("phone") String phone);

    int insert(User user);

    int updateById(User user);

    List<User> selectAll();

    /** 按昵称/手机号搜索用户 */
    List<User> selectByKeyword(@Param("keyword") String keyword);
}
