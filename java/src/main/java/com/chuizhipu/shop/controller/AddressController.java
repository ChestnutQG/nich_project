package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.Address;
import com.chuizhipu.shop.service.AddressService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/addresses")
public class AddressController {

    private final AddressService addressService;

    public AddressController(AddressService addressService) {
        this.addressService = addressService;
    }

    /** GET /api/addresses — 当前用户地址列表 */
    @GetMapping
    public R list(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        List<Address> list = addressService.getByUserId(userId);
        return R.ok(list);
    }

    /** GET /api/addresses/{id} */
    @GetMapping("/{id}")
    public R detail(@PathVariable Long id) {
        Address addr = addressService.getById(id);
        if (addr == null) return R.error("地址不存在");
        return R.ok(addr);
    }

    /** POST /api/addresses — 新增/更新地址 */
    @PostMapping
    public R save(HttpServletRequest request, @RequestBody Address address) {
        Long userId = (Long) request.getAttribute("currentUserId");
        if (userId == null) return R.error(401, "请先登录");
        address.setUserId(userId);
        Long id = addressService.save(address);
        return R.ok(id);
    }

    /** DELETE /api/addresses/{id} */
    @DeleteMapping("/{id}")
    public R delete(@PathVariable Long id) {
        addressService.delete(id);
        return R.ok(null);
    }
}
