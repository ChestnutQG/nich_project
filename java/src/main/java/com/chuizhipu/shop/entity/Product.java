package com.chuizhipu.shop.entity;

import java.time.LocalDateTime;

/**
 * 非遗商品
 */
public class Product {
    private Long id;
    private String name;
    private String description;
    private Long categoryId;
    private Long artisanId;
    private String images;        // JSON 数组
    private String videoUrl;      // 视频URL（可选）
    private Long price;           // 现价（分）
    private Long originalPrice;   // 原价（分）
    private Integer stock;
    private Integer sales;
    private String region;
    private String craftType;
    private String story;
    private String craftProcess;  // JSON 数组
    private Double rating;
    private String tags;          // 逗号分隔
    private String auditStatus;   // pending | approved | rejected
    private Integer isOnSale;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    // ---- 关联（非数据库字段，手动填充） ----
    private String categoryName;
    private String artisanName;
    private java.util.List<ProductSku> skus;
    private Boolean isCollect;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    public Long getArtisanId() { return artisanId; }
    public void setArtisanId(Long artisanId) { this.artisanId = artisanId; }
    public String getImages() { return images; }
    public void setImages(String images) { this.images = images; }
    public String getVideoUrl() { return videoUrl; }
    public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }
    public Long getPrice() { return price; }
    public void setPrice(Long price) { this.price = price; }
    public Long getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(Long originalPrice) { this.originalPrice = originalPrice; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    public Integer getSales() { return sales; }
    public void setSales(Integer sales) { this.sales = sales; }
    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }
    public String getCraftType() { return craftType; }
    public void setCraftType(String craftType) { this.craftType = craftType; }
    public String getStory() { return story; }
    public void setStory(String story) { this.story = story; }
    public String getCraftProcess() { return craftProcess; }
    public void setCraftProcess(String craftProcess) { this.craftProcess = craftProcess; }
    public Double getRating() { return rating; }
    public void setRating(Double rating) { this.rating = rating; }
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    public String getAuditStatus() { return auditStatus; }
    public void setAuditStatus(String auditStatus) { this.auditStatus = auditStatus; }
    public Integer getIsOnSale() { return isOnSale; }
    public void setIsOnSale(Integer isOnSale) { this.isOnSale = isOnSale; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getArtisanName() { return artisanName; }
    public void setArtisanName(String artisanName) { this.artisanName = artisanName; }
    public java.util.List<ProductSku> getSkus() { return skus; }
    public void setSkus(java.util.List<ProductSku> skus) { this.skus = skus; }
    public Boolean getIsCollect() { return isCollect; }
    public void setIsCollect(Boolean isCollect) { this.isCollect = isCollect; }
}
