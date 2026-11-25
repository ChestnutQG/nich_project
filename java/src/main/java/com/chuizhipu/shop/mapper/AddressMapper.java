package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Address;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AddressMapper {

    List<Address> selectByUserId(@Param("userId") Long userId);

    Address selectById(@Param("id") Long id);

    int insert(Address address);

    int updateById(Address address);

    int deleteById(@Param("id") Long id);

    /** 取消该用户其他默认地址 */
    int clearDefault(@Param("userId") Long userId);
}
