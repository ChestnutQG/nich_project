package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Favorite;
import com.chuizhipu.shop.mapper.FavoriteMapper;
import com.chuizhipu.shop.vo.ProductVO;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * 商品收藏服务
 */
@Service
public class FavoriteService {

    private final FavoriteMapper favoriteMapper;
    private final ProductService productService;

    public FavoriteService(FavoriteMapper favoriteMapper, ProductService productService) {
        this.favoriteMapper = favoriteMapper;
        this.productService = productService;
    }

    /** 添加收藏（已收藏则忽略，保证幂等） */
    public void add(Long userId, Long productId) {
        if (favoriteMapper.exists(userId, productId) > 0) return;
        Favorite f = new Favorite();
        f.setUserId(userId);
        f.setProductId(productId);
        favoriteMapper.insert(f);
    }

    /** 取消收藏 */
    public void remove(Long userId, Long productId) {
        favoriteMapper.delete(userId, productId);
    }

    /** 是否已收藏 */
    public boolean isFavorited(Long userId, Long productId) {
        return favoriteMapper.exists(userId, productId) > 0;
    }

    /** 我的收藏商品列表 */
    public List<ProductVO> getMyFavorites(Long userId) {
        List<Long> ids = favoriteMapper.selectProductIdsByUserId(userId, null);
        List<ProductVO> result = new ArrayList<>();
        for (Long pid : ids) {
            ProductVO vo = productService.getProductDetail(pid, userId);
            if (vo != null) result.add(vo);
        }
        return result;
    }
}
