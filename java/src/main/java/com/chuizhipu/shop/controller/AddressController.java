package com.chuizhipu.shop.controller;

import com.chuizhipu.shop.common.R;
import com.chuizhipu.shop.entity.Address;
import com.chuizhipu.shop.service.AddressService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 收货地址接口
 */
@RestController
@RequestMapping("/api/addresses")
public class AddressController {

    private final AddressService addressService;

    public AddressController(AddressService addressService) {
        this.addressService = addressService;
    }

    /** GET /api/addresses?userId=1 */
    @GetMapping
    public R list(@RequestParam Long userId) {
        List<Address> list = addressService.getByUserId(userId);
        return R.ok(list);
    }

    /** GET /api/addresses/{id} */
    @GetMapping("/{id}")
    public R detail(@PathVariable Long id) {
        Address addr = addressService.getById(id);
        if (addr == null) {
            return R.error("地址不存在");
        }
        return R.ok(addr);
    }

    /** POST /api/addresses */
    @PostMapping
    public R save(@RequestBody Address address) {
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
