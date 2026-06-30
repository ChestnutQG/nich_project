package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.service.ArtisanService;
import com.chuizhipu.shop.service.ProductService;
import com.chuizhipu.shop.vo.ArtisanVO;
import com.chuizhipu.shop.vo.ProductVO;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 匠人接口
 */
@RestController
@RequestMapping("/api/artisans")
public class ArtisanController {

    private final ArtisanService artisanService;
    private final ProductService productService;

    public ArtisanController(ArtisanService artisanService, ProductService productService) {
        this.artisanService = artisanService;
        this.productService = productService;
    }

    /** GET /api/artisans — 匠人列表 */
    @GetMapping
    public R list(@RequestParam(required = false) String craftType,
                  @RequestParam(defaultValue = "1") int page,
                  @RequestParam(defaultValue = "10") int size,
                  @RequestParam(required = false) Long userId) {
        List<ArtisanVO> list = artisanService.getList(craftType, page, size, userId);
        long total = artisanService.countList(craftType);
        Map<String, Object> data = R.pageData(list, total, page, size);
        return R.ok(data);
    }

    /** GET /api/artisans/top — 热门匠人（首页推荐） */
    @GetMapping("/top")
    public R top(@RequestParam(defaultValue = "6") int limit,
                 @RequestParam(required = false) Long userId) {
        List<ArtisanVO> list = artisanService.getTop(limit, userId);
        return R.ok(list);
    }

    /** GET /api/artisans/search — 搜索匠人（按名称/技艺/简介） */
    @GetMapping("/search")
    public R search(@RequestParam String keyword,
                    @RequestParam(required = false) Long userId) {
        List<ArtisanVO> list = artisanService.searchArtisans(keyword, userId);
        return R.ok(list);
    }

    /** GET /api/artisans/{id} — 匠人详情 */
    @GetMapping("/{id}")
    public R detail(@PathVariable Long id,
                    @RequestParam(required = false) Long userId) {
        ArtisanVO artisan = artisanService.getDetail(id, userId);
        if (artisan == null) {
            return R.error("匠人不存在");
        }
        return R.ok(artisan);
    }

    /** GET /api/artisans/{id}/products — 匠人的作品 */
    @GetMapping("/{id}/products")
    public R products(@PathVariable Long id,
                      @RequestParam(required = false) Long userId) {
        List<ProductVO> products = productService.getProductsByArtisan(id, userId);
        return R.ok(products);
    }

    /** PUT /api/artisans/me/intro — 修改自己的匠人简介（需登录） */
    @PutMapping("/me/intro")
    public R updateMyIntro(HttpServletRequest request, @RequestBody IntroReq req) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        boolean ok = artisanService.updateMyIntro(userId, req.getIntro() != null ? req.getIntro().trim() : "");
        if (!ok) return R.error("你还不是匠人，发布作品后才有匠人主页");
        return R.ok(null);
    }

    public static class IntroReq {
        private String intro;
        public String getIntro() { return intro; }
        public void setIntro(String intro) { this.intro = intro; }
    }
}
