package com.nonheritage.demo.dto;

/** 下单请求DTO */
public class OrderRequest {
    private Long productId; // 商品ID

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
}
