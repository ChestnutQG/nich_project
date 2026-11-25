package com.nonheritage.demo.repository;

import com.nonheritage.demo.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/** 商品数据访问层 */
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByContentId(Long contentId); // 按内容ID查询
    List<Product> findBySellerId(Long sellerId);   // 按卖家ID查询
}
