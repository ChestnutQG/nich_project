package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.Category;
import com.chuizhipu.shop.service.CategoryService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 分类接口
 */
@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    /** GET /api/categories — 全部分类 */
    @GetMapping
    public R list() {
        List<Category> categories = categoryService.getAllCategories();
        return R.ok(categories);
    }

    /** GET /api/categories/{id} — 分类详情 */
    @GetMapping("/{id}")
    public R detail(@PathVariable Long id) {
        Category cat = categoryService.getById(id);
        if (cat == null) {
            return R.error("分类不存在");
        }
        return R.ok(cat);
    }

    /** GET /api/categories/{id}/children — 子分类 */
    @GetMapping("/{id}/children")
    public R children(@PathVariable Long id) {
        List<Category> children = categoryService.getByParentId(id);
        return R.ok(children);
    }
}
