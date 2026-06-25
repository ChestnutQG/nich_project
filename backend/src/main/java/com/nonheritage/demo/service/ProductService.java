package com.nonheritage.demo.service;

import com.nonheritage.demo.entity.Product;
import com.nonheritage.demo.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;

/** 商品服务：按内容查询商品、获取全部商品 */
@Service
public class ProductService {
    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    /** 根据内容ID查询商品 @param contentId 内容ID @return 商品列表 */
    public List<Product> getByContentId(Long contentId) {
        return productRepository.findByContentId(contentId);
    }

    /** 获取全部商品 @return 商品列表 */
    public List<Product> getAll() {
        return productRepository.findAll();
    }
}
