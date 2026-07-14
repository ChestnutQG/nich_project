package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Category;
import com.chuizhipu.shop.mapper.CategoryMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {

    private final CategoryMapper categoryMapper;

    public CategoryService(CategoryMapper categoryMapper) {
        this.categoryMapper = categoryMapper;
    }

    public List<Category> getAllCategories() {
        return categoryMapper.selectAll();
    }

    public List<Category> getByParentId(Long parentId) {
        return categoryMapper.selectByParentId(parentId);
    }

    public Category getById(Long id) {
        return categoryMapper.selectById(id);
    }
}
