package com.nonheritage.demo.entity;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 非遗商品实体类 */
@Entity
public class Product {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;               // 主键
    private Long contentId;        // 关联的内容ID
    private Long sellerId;         // 卖家用户ID
    private String name;           // 商品名称
    private BigDecimal price;      // 价格
    private Integer stock = 0;     // 库存数量
    @Column(columnDefinition = "TEXT")
    private String description;    // 商品描述
    @Column(columnDefinition = "TEXT")
    private String images;         // 商品图片URL（JSON数组字符串）
    private String status = "on_sale";   // 状态：on_sale / sold_out / off_shelf
    private LocalDateTime createdAt = LocalDateTime.now(); // 创建时间

    public Product() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getContentId() { return contentId; }
    public void setContentId(Long contentId) { this.contentId = contentId; }
    public Long getSellerId() { return sellerId; }
    public void setSellerId(Long sellerId) { this.sellerId = sellerId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImages() { return images; }
    public void setImages(String images) { this.images = images; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
