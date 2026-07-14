package com.chuizhipu.shop.vo;

/**
 * 订单项 VO — 匹配前端 OrderItem 接口
 */
public class OrderItemVO {

    private String productId;
    private String productName;
    private String productImage;
    private String skuId;
    private String skuName;
    private Long price;
    private Integer quantity;

    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getProductImage() { return productImage; }
    public void setProductImage(String productImage) { this.productImage = productImage; }
    public String getSkuId() { return skuId; }
    public void setSkuId(String skuId) { this.skuId = skuId; }
    public String getSkuName() { return skuName; }
    public void setSkuName(String skuName) { this.skuName = skuName; }
    public Long getPrice() { return price; }
    public void setPrice(Long price) { this.price = price; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
}
