package com.chuizhipu.shop.service;

import com.chuizhipu.shop.common.EntityUtils;
import com.chuizhipu.shop.entity.CartItem;
import com.chuizhipu.shop.entity.Product;
import com.chuizhipu.shop.entity.ProductSku;
import com.chuizhipu.shop.mapper.CartItemMapper;
import com.chuizhipu.shop.mapper.ProductMapper;
import com.chuizhipu.shop.mapper.ProductSkuMapper;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CartService {

    private final CartItemMapper cartMapper;
    private final ProductMapper productMapper;
    private final ProductSkuMapper skuMapper;

    public CartService(CartItemMapper cartMapper, ProductMapper productMapper,
                       ProductSkuMapper skuMapper) {
        this.cartMapper = cartMapper;
        this.productMapper = productMapper;
        this.skuMapper = skuMapper;
    }

    public List<Map<String, Object>> getCartItems(Long userId) {
        List<CartItem> items = cartMapper.selectByUserId(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (CartItem item : items) {
            Product p = productMapper.selectById(item.getProductId());
            ProductSku sku = item.getSkuId() != null ? skuMapper.selectById(item.getSkuId()) : null;
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", item.getId().toString());
            map.put("productId", item.getProductId().toString());
            map.put("productName", p != null ? p.getName() : "");
            map.put("productImage", p != null ? (EntityUtils.parseStrList(p.getImages()).isEmpty() ? "" :
                    EntityUtils.parseStrList(p.getImages()).get(0)) : "");
            map.put("skuId", item.getSkuId() != null ? item.getSkuId().toString() : "");
            map.put("skuName", sku != null ? sku.getName() : "默认");
            map.put("price", sku != null ? sku.getPrice() : (p != null ? p.getPrice() : 0));
            map.put("quantity", item.getQuantity());
            map.put("isChecked", item.getIsChecked() == 1);
            map.put("stock", sku != null ? sku.getStock() : (p != null ? p.getStock() : 0));
            result.add(map);
        }
        return result;
    }

    public void addToCart(CartItem item) {
        if (item.getSkuId() != null) {
            CartItem exist = cartMapper.selectByUserAndSku(item.getUserId(), item.getSkuId());
            if (exist != null) {
                cartMapper.updateQuantity(exist.getId(), exist.getQuantity() + Math.max(item.getQuantity(), 1));
                return;
            }
        }
        cartMapper.insert(item);
    }

    public void updateQuantity(Long id, Integer quantity) {
        if (quantity != null && quantity > 0) {
            cartMapper.updateQuantity(id, quantity);
        }
    }

    public void updateChecked(Long id, Integer isChecked) {
        cartMapper.updateChecked(id, isChecked != null ? isChecked : 1);
    }

    public void updateAllChecked(Long userId, Integer isChecked) {
        cartMapper.updateAllChecked(userId, isChecked != null ? isChecked : 1);
    }

    public void removeItem(Long id) {
        cartMapper.deleteById(id);
    }

    public int getCartCount(Long userId) {
        return cartMapper.countByUserId(userId);
    }
}
