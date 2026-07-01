package com.chuizhipu.shop.service;

import com.chuizhipu.shop.common.EntityUtils;
import com.chuizhipu.shop.entity.Artisan;
import com.chuizhipu.shop.entity.Product;
import com.chuizhipu.shop.entity.ProductSku;
import com.chuizhipu.shop.entity.User;
import com.chuizhipu.shop.mapper.ArtisanMapper;
import com.chuizhipu.shop.mapper.FavoriteMapper;
import com.chuizhipu.shop.mapper.FollowMapper;
import com.chuizhipu.shop.mapper.ProductMapper;
import com.chuizhipu.shop.mapper.ProductSkuMapper;
import com.chuizhipu.shop.mapper.UserMapper;
import com.chuizhipu.shop.vo.CraftStepVO;
import com.chuizhipu.shop.vo.ProductVO;
import com.chuizhipu.shop.vo.SkuVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class ProductService {

    private final ProductMapper productMapper;
    private final ProductSkuMapper skuMapper;
    private final FavoriteMapper favoriteMapper;
    private final FollowMapper followMapper;
    private final NotificationService notificationService;
    private final ArtisanMapper artisanMapper;
    private final UserMapper userMapper;

    public ProductService(ProductMapper productMapper,
                          ProductSkuMapper skuMapper,
                          FavoriteMapper favoriteMapper,
                          FollowMapper followMapper,
                          NotificationService notificationService,
                          ArtisanMapper artisanMapper,
                          UserMapper userMapper) {
        this.productMapper = productMapper;
        this.skuMapper = skuMapper;
        this.favoriteMapper = favoriteMapper;
        this.followMapper = followMapper;
        this.notificationService = notificationService;
        this.artisanMapper = artisanMapper;
        this.userMapper = userMapper;
    }

    /** 首页推荐 */
    public List<ProductVO> getRecommendProducts(Long userId) {
        List<Product> products = productMapper.selectRecommend();
        return toVOList(products, userId);
    }

    /** 分页商品列表 */
    public List<ProductVO> getProductList(Long categoryId, int page, int size,
                                           String sortBy, Long userId) {
        int offset = (page - 1) * size;
        List<Product> products = productMapper.selectPage(categoryId, sortBy, offset, size);
        return toVOList(products, userId);
    }

    /** 分页总数 */
    public long countProducts(Long categoryId) {
        return productMapper.countPage(categoryId);
    }

    /** 商品详情 */
    public ProductVO getProductDetail(Long id, Long userId) {
        Product p = productMapper.selectById(id);
        if (p == null) return null;
        return toVO(p, userId);
    }

    /** 搜索 */
    public List<ProductVO> searchProducts(String keyword, int page, int size, Long userId) {
        int offset = (page - 1) * size;
        List<Product> products = productMapper.search(keyword, offset, size);
        return toVOList(products, userId);
    }

    /** 搜索总数 */
    public long countSearch(String keyword) {
        return productMapper.countSearch(keyword);
    }

    /** 根据匠人查商品 */
    public List<ProductVO> getProductsByArtisan(Long artisanId, Long userId) {
        List<Product> products = productMapper.selectByArtisanId(artisanId);
        return toVOList(products, userId);
    }

    public List<ProductVO> getMyProducts(Long userId) {
        return toVOList(productMapper.selectByOwnerUserId(userId), userId);
    }

    @Transactional
    public boolean deleteOwnProduct(Long productId, Long userId) {
        Long ownerId = productMapper.selectArtisanUserIdByProductId(productId);
        if (ownerId == null || !ownerId.equals(userId)) return false;
        return productMapper.softDelete(productId) > 0;
    }

    @Transactional
    public boolean deleteProductAsAdmin(Long productId) {
        Product product = productMapper.selectById(productId);
        if (product == null) return false;
        Long ownerId = productMapper.selectArtisanUserIdByProductId(productId);
        if (productMapper.softDelete(productId) == 0) return false;

        if (ownerId != null) {
            String productName = product.getName() != null ? product.getName() : "未命名作品";
            notificationService.notify(
                    ownerId,
                    "product_deleted",
                    "作品删除通知",
                    "您的作品《" + productName + "》已被管理员删除，如有疑问请联系平台管理员。",
                    null
            );
        }
        return true;
    }

    /** 发布商品 — 匠人按发布者本人解析，避免都挂到同一个匠人 */
    @Transactional
    public Long publishProduct(Long userId, Product product, List<ProductSku> skus) {
        product.setArtisanId(resolveArtisanId(userId, product));
        product.setSales(0);
        product.setRating(5.0);
        product.setIsOnSale(1);
        productMapper.insert(product);

        if (skus != null && !skus.isEmpty()) {
            skus.forEach(sku -> sku.setProductId(product.getId()));
            skuMapper.insertBatch(skus);
        }

        // 通知关注该匠人的用户：匠人上新
        try {
            notifyFollowersNewProduct(product);
        } catch (Exception e) {
            // 通知失败不影响发布
        }

        return product.getId();
    }

    /** 取发布者对应的匠人 id：已有匠人档案则用本人的，否则用用户信息自动建一个 */
    private Long resolveArtisanId(Long userId, Product product) {
        Artisan exist = artisanMapper.selectByUserId(userId);
        if (exist != null) {
            return exist.getId();
        }
        User u = userMapper.selectById(userId);
        Artisan a = new Artisan();
        a.setUserId(userId);
        a.setName(u != null && u.getNickname() != null ? u.getNickname() : "匠人" + userId);
        a.setAvatar(u != null ? u.getAvatar() : null);
        a.setTitle("手艺人");
        a.setLevel(1);
        a.setCraftType(product.getCraftType());
        a.setProvince(product.getRegion());
        a.setWorksCount(0);
        a.setFollowersCount(0);
        artisanMapper.insert(a);
        return a.getId();
    }

    /** 更新商品（带降价通知） */
    @Transactional
    public void updateProduct(Product product) {
        // 查旧价格以判断是否降价
        Product old = productMapper.selectById(product.getId());
        boolean priceDropped = old != null && old.getPrice() != null &&
                product.getPrice() != null && product.getPrice() < old.getPrice();

        productMapper.update(product);

        // 降价通知收藏者
        if (priceDropped) {
            try {
                notifyFavoritesPriceDrop(product, old.getPrice());
            } catch (Exception e) {
                // ignore
            }
        }
    }

    /** 匠人上新 → 通知关注者 */
    private void notifyFollowersNewProduct(Product product) {
        if (product.getArtisanId() == null) return;
        List<Long> followerUserIds = followMapper.selectUserIdsByArtisanId(product.getArtisanId());
        if (followerUserIds == null || followerUserIds.isEmpty()) return;
        String msg = "您关注的匠人「" + (product.getArtisanName() != null ? product.getArtisanName() : "") +
                "」发布了新作品《" + product.getName() + "》，快来看看吧！";
        for (Long userId : followerUserIds) {
            notificationService.notify(userId, "artisan_new", msg, product.getId());
        }
    }

    /** 降价 → 通知收藏者 */
    private void notifyFavoritesPriceDrop(Product product, Long oldPrice) {
        Long productId = product.getId();
        List<Long> userIds = favoriteMapper.selectUserIdsByProductId(productId);
        if (userIds == null || userIds.isEmpty()) return;
        long diff = oldPrice - product.getPrice();
        String diffStr = diff >= 100 ? (diff / 100) + "元" : diff + "分";
        String msg = "您收藏的商品《" + product.getName() + "》降价了！从 ¥" +
                String.format("%.2f", oldPrice / 100.0) + " 降至 ¥" +
                String.format("%.2f", product.getPrice() / 100.0) +
                "（降了 " + diffStr + "），赶紧去看看！";
        for (Long userId : userIds) {
            notificationService.notify(userId, "price_drop", msg, productId);
        }
    }

    // ---- Entity → VO 转换 ----

    private List<ProductVO> toVOList(List<Product> products, Long userId) {
        if (products.isEmpty()) return Collections.emptyList();

        // 批量查 SKU
        List<Long> productIds = products.stream().map(Product::getId).collect(Collectors.toList());
        List<ProductSku> allSkus = skuMapper.selectByProductIds(productIds);
        Map<Long, List<ProductSku>> skuMap = allSkus.stream()
                .collect(Collectors.groupingBy(ProductSku::getProductId));

        // 批量查收藏状态
        Set<Long> favIds = Collections.emptySet();
        if (userId != null) {
            List<Long> fids = favoriteMapper.selectProductIdsByUserId(userId, productIds);
            favIds = new HashSet<>(fids);
        }
        final Set<Long> finalFavIds = favIds;

        return products.stream()
                .map(p -> entityToVO(p, skuMap.getOrDefault(p.getId(), Collections.emptyList()),
                        finalFavIds.contains(p.getId())))
                .collect(Collectors.toList());
    }

    private ProductVO toVO(Product p, Long userId) {
        List<ProductSku> skus = skuMapper.selectByProductId(p.getId());
        boolean isCollect = userId != null && favoriteMapper.exists(userId, p.getId()) > 0;
        return entityToVO(p, skus, isCollect);
    }

    private ProductVO entityToVO(Product p, List<ProductSku> skus, boolean isCollect) {
        ProductVO vo = new ProductVO();
        vo.setId(EntityUtils.strId(p.getId()));
        vo.setName(p.getName());
        vo.setDescription(p.getDescription());
        vo.setCategoryId(EntityUtils.strId(p.getCategoryId()));
        vo.setCategoryName(p.getCategoryName());
        vo.setArtisanId(EntityUtils.strId(p.getArtisanId()));
        vo.setArtisanName(p.getArtisanName());
        vo.setArtisanAvatar(p.getArtisanAvatar());
        vo.setImages(EntityUtils.parseStrList(p.getImages()));
        vo.setVideoUrl(p.getVideoUrl());
        vo.setAuditStatus(p.getAuditStatus());
        // 默认按可售（兼容旧数据：null 视为可售）
        vo.setIsSellable(p.getIsSellable() == null || p.getIsSellable() == 1);
        vo.setPrice(p.getPrice());
        vo.setOriginalPrice(p.getOriginalPrice());
        vo.setStock(p.getStock());
        vo.setSales(p.getSales());
        vo.setRegion(p.getRegion());
        vo.setCraftType(p.getCraftType());
        vo.setStory(p.getStory());
        vo.setCraftProcess(EntityUtils.parseJsonList(p.getCraftProcess(), CraftStepVO.class));
        vo.setSkus(skus.stream().map(this::skuToVO).collect(Collectors.toList()));
        vo.setRating(p.getRating());
        vo.setTags(EntityUtils.parseTags(p.getTags()));
        vo.setIsCollect(isCollect);
        vo.setCreateTime(EntityUtils.toEpoch(p.getCreateTime()));
        return vo;
    }

    private SkuVO skuToVO(ProductSku sku) {
        SkuVO vo = new SkuVO();
        vo.setId(EntityUtils.strId(sku.getId()));
        vo.setName(sku.getName());
        vo.setPrice(sku.getPrice());
        vo.setStock(sku.getStock());
        vo.setImage(sku.getImage());
        return vo;
    }
}
