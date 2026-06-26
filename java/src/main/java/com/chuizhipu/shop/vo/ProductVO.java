package com.chuizhipu.shop.vo;

import java.util.List;

/**
 * 商品详情 VO — 精确匹配前端 Product 接口字段
 */
public class ProductVO {

    private String id;
    private String name;
    private String description;
    private String categoryId;
    private String categoryName;
    private String artisanId;
    private String artisanName;
    private List<String> images;
    private String videoUrl;       // 视频URL
    private Long price;            // 现价（分）
    private Long originalPrice;    // 原价（分）
    private Integer stock;
    private Integer sales;
    private String region;
    private String craftType;
    private String story;
    private List<CraftStepVO> craftProcess;
    private List<SkuVO> skus;
    private Double rating;
    private List<String> tags;
    private String auditStatus;    // pending | approved | rejected
    private Boolean isCollect;
    private Long createTime;       // 毫秒时间戳

    // ---- getters / setters ----
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCategoryId() { return categoryId; }
    public void setCategoryId(String categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getArtisanId() { return artisanId; }
    public void setArtisanId(String artisanId) { this.artisanId = artisanId; }
    public String getArtisanName() { return artisanName; }
    public void setArtisanName(String artisanName) { this.artisanName = artisanName; }
    public List<String> getImages() { return images; }
    public void setImages(List<String> images) { this.images = images; }
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
    public List<CraftStepVO> getCraftProcess() { return craftProcess; }
    public void setCraftProcess(List<CraftStepVO> craftProcess) { this.craftProcess = craftProcess; }
    public List<SkuVO> getSkus() { return skus; }
    public void setSkus(List<SkuVO> skus) { this.skus = skus; }
    public Double getRating() { return rating; }
    public void setRating(Double rating) { this.rating = rating; }
    public List<String> getTags() { return tags; }
    public void setTags(List<String> tags) { this.tags = tags; }
    public String getAuditStatus() { return auditStatus; }
    public void setAuditStatus(String auditStatus) { this.auditStatus = auditStatus; }
    public Boolean getIsCollect() { return isCollect; }
    public void setIsCollect(Boolean isCollect) { this.isCollect = isCollect; }
    public Long getCreateTime() { return createTime; }
    public void setCreateTime(Long createTime) { this.createTime = createTime; }
}
