package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Category;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CategoryMapper {

    List<Category> selectAll();

    List<Category> selectByParentId(@Param("parentId") Long parentId);

    Category selectById(@Param("id") Long id);

    int insert(Category category);

    int updateById(Category category);

    int deleteById(@Param("id") Long id);
}
