package com.chuizhipu.shop.vo;

/**
 * SKU VO — 匹配前端 Sku 接口
 */
public class SkuVO {

    private String id;
    private String name;
    private Long price;
    private Integer stock;
    private String image;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Long getPrice() { return price; }
    public void setPrice(Long price) { this.price = price; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
}
