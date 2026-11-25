package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Product;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ProductServiceTest {

    @Test
    void mixesRecentProductsIntoProtectedSlotsAndRemovesDuplicates() {
        Product popular1 = product(1);
        Product popular2 = product(2);
        Product popular3 = product(3);
        Product popular4 = product(4);
        Product recent1 = product(5);

        List<Product> result = ProductService.mixRecommendations(
                List.of(popular1, popular2, popular3, popular4, recent1),
                List.of(recent1, popular2),
                5
        );

        assertEquals(List.of(1L, 5L, 2L, 3L, 4L),
                result.stream().map(Product::getId).toList());
    }

    private Product product(long id) {
        Product product = new Product();
        product.setId(id);
        return product;
    }
}
