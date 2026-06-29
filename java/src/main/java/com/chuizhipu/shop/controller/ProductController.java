package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.Product;
import com.chuizhipu.shop.entity.ProductSku;
import com.chuizhipu.shop.service.ProductService;
import com.chuizhipu.shop.vo.ProductVO;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    /** 从 request 中取 userId（已登录则返回，否则返回 null） */
    private Long getCurrentUserId(HttpServletRequest request) {
        return (Long) request.getAttribute("currentUserId");
    }

    /** GET /api/products/recommend — 首页推荐 */
    @GetMapping("/recommend")
    public R recommend(HttpServletRequest request) {
        Long userId = getCurrentUserId(request);
        List<ProductVO> list = productService.getRecommendProducts(userId);
        return R.ok(list);
    }

    /** GET /api/products — 分页列表 */
    @GetMapping
    public R list(HttpServletRequest request,
                  @RequestParam(required = false) Long categoryId,
                  @RequestParam(defaultValue = "1") int page,
                  @RequestParam(defaultValue = "10") int size,
                  @RequestParam(required = false) String sortBy) {
        Long userId = getCurrentUserId(request);
        List<ProductVO> list = productService.getProductList(categoryId, page, size, sortBy, userId);
        long total = productService.countProducts(categoryId);
        Map<String, Object> data = R.pageData(list, total, page, size);
        return R.ok(data);
    }

    /** GET /api/products/{id} — 商品详情 */
    @GetMapping("/{id}")
    public R detail(HttpServletRequest request, @PathVariable Long id) {
        Long userId = getCurrentUserId(request);
        ProductVO product = productService.getProductDetail(id, userId);
        if (product == null) return R.error("商品不存在");
        return R.ok(product);
    }

    /** GET /api/products/search — 搜索 */
    @GetMapping("/search")
    public R search(HttpServletRequest request,
                    @RequestParam String keyword,
                    @RequestParam(defaultValue = "1") int page,
                    @RequestParam(defaultValue = "10") int size) {
        Long userId = getCurrentUserId(request);
        List<ProductVO> list = productService.searchProducts(keyword, page, size, userId);
        long total = productService.countSearch(keyword);
        Map<String, Object> data = R.pageData(list, total, page, size);
        return R.ok(data);
    }

    /** POST /api/products — 发布商品（需登录） */
    @PostMapping
    public R publish(HttpServletRequest request, @RequestBody PublishReq req) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        if (req.getName() == null || req.getName().isBlank()) {
            return R.error("商品名称不能为空");
        }
        if (req.getPrice() == null || req.getPrice() <= 0) {
            return R.error("价格不能为空");
        }
        Long id = productService.publishProduct(req.toProduct(), req.toSkuList());
        return R.ok(id);
    }

    // 接收前端的发布请求体
    public static class PublishReq {
        private String name;
        private String description;
        private Long categoryId;
        private Long artisanId;
        private List<String> images;
        private Long price;
        private Long originalPrice;
        private Integer stock;
        private String region;
        private String craftType;
        private String story;
        private String tags;
        private List<SkuReq> skus;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public Long getCategoryId() { return categoryId; }
        public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
        public Long getArtisanId() { return artisanId; }
        public void setArtisanId(Long artisanId) { this.artisanId = artisanId; }
        public List<String> getImages() { return images; }
        public void setImages(List<String> images) { this.images = images; }
        public Long getPrice() { return price; }
        public void setPrice(Long price) { this.price = price; }
        public Long getOriginalPrice() { return originalPrice; }
        public void setOriginalPrice(Long originalPrice) { this.originalPrice = originalPrice; }
        public Integer getStock() { return stock; }
        public void setStock(Integer stock) { this.stock = stock; }
        public String getRegion() { return region; }
        public void setRegion(String region) { this.region = region; }
        public String getCraftType() { return craftType; }
        public void setCraftType(String craftType) { this.craftType = craftType; }
        public String getStory() { return story; }
        public void setStory(String story) { this.story = story; }
        public String getTags() { return tags; }
        public void setTags(String tags) { this.tags = tags; }
        public List<SkuReq> getSkus() { return skus; }
        public void setSkus(List<SkuReq> skus) { this.skus = skus; }

        public Product toProduct() {
            Product p = new Product();
            p.setName(name);
            p.setDescription(description);
            p.setCategoryId(categoryId);
            p.setArtisanId(artisanId);
            p.setImages(com.chuizhipu.shop.common.EntityUtils.toJson(images));
            p.setPrice(price);
            p.setOriginalPrice(originalPrice);
            p.setStock(stock != null ? stock : 1);
            p.setRegion(region);
            p.setCraftType(craftType);
            p.setStory(story);
            p.setTags(tags);
            return p;
        }

        public List<ProductSku> toSkuList() {
            if (skus == null || skus.isEmpty()) return List.of();
            return skus.stream().map(s -> {
                ProductSku sku = new ProductSku();
                sku.setName(s.name);
                sku.setPrice(s.price);
                sku.setStock(s.stock != null ? s.stock : 0);
                sku.setImage(s.image);
                return sku;
            }).toList();
        }
    }

    /** PUT /api/products/{id} — 更新商品（价格降低时自动通知收藏者） */
    @PutMapping("/{id}")
    public R updateProduct(@PathVariable Long id, @RequestBody ProductUpdateReq req) {
        Product product = new Product();
        product.setId(id);
        if (req.getName() != null) product.setName(req.getName());
        if (req.getDescription() != null) product.setDescription(req.getDescription());
        if (req.getPrice() != null) product.setPrice(req.getPrice());
        if (req.getOriginalPrice() != null) product.setOriginalPrice(req.getOriginalPrice());
        if (req.getStock() != null) product.setStock(req.getStock());
        if (req.getImages() != null) product.setImages(com.chuizhipu.shop.common.EntityUtils.toJson(req.getImages()));
        if (req.getTags() != null) product.setTags(req.getTags());
        productService.updateProduct(product);
        return R.ok(null);
    }

    public static class ProductUpdateReq {
        private String name;
        private String description;
        private List<String> images;
        private Long price;
        private Long originalPrice;
        private Integer stock;
        private String tags;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public List<String> getImages() { return images; }
        public void setImages(List<String> images) { this.images = images; }
        public Long getPrice() { return price; }
        public void setPrice(Long price) { this.price = price; }
        public Long getOriginalPrice() { return originalPrice; }
        public void setOriginalPrice(Long originalPrice) { this.originalPrice = originalPrice; }
        public Integer getStock() { return stock; }
        public void setStock(Integer stock) { this.stock = stock; }
        public String getTags() { return tags; }
        public void setTags(String tags) { this.tags = tags; }
    }

    public static class SkuReq {
        private String name;
        private Long price;
        private Integer stock;
        private String image;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public Long getPrice() { return price; }
        public void setPrice(Long price) { this.price = price; }
        public Integer getStock() { return stock; }
        public void setStock(Integer stock) { this.stock = stock; }
        public String getImage() { return image; }
        public void setImage(String image) { this.image = image; }
    }
}
