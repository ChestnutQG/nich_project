package com.nonheritage.demo.controller;

import com.nonheritage.demo.dto.ApiResponse;
import com.nonheritage.demo.service.ProductService;
import org.springframework.web.bind.annotation.*;

/** 商品控制器：按内容查询商品、获取全部商品 */
@RestController
@RequestMapping("/api/products")
public class ProductController {
    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    /** 查询商品 @param contentId 内容ID（可选，不传则查全部） @return 商品列表 */
    @GetMapping
    public ApiResponse<?> getByContent(@RequestParam(required = false) Long contentId) {
        if (contentId != null) {
            return ApiResponse.ok(productService.getByContentId(contentId));
        }
        return ApiResponse.ok(productService.getAll());
    }
}
