package com.chuizhipu.shop.service;

import com.chuizhipu.shop.common.EntityUtils;
import com.chuizhipu.shop.entity.Product;
import com.chuizhipu.shop.entity.ProductSku;
import com.chuizhipu.shop.mapper.FavoriteMapper;
import com.chuizhipu.shop.mapper.ProductMapper;
import com.chuizhipu.shop.mapper.ProductSkuMapper;
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

    public ProductService(ProductMapper productMapper,
                          ProductSkuMapper skuMapper,
                          FavoriteMapper favoriteMapper) {
        this.productMapper = productMapper;
        this.skuMapper = skuMapper;
        this.favoriteMapper = favoriteMapper;
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

    /** 发布商品 */
    @Transactional
    public Long publishProduct(Product product, List<ProductSku> skus) {
        product.setSales(0);
        product.setRating(5.0);
        product.setIsOnSale(1);
        productMapper.insert(product);

        if (skus != null && !skus.isEmpty()) {
            skus.forEach(sku -> sku.setProductId(product.getId()));
            skuMapper.insertBatch(skus);
        }
        return product.getId();
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
        vo.setImages(EntityUtils.parseStrList(p.getImages()));
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
