package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Address;
import com.chuizhipu.shop.mapper.AddressMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AddressService {

    private final AddressMapper addressMapper;

    public AddressService(AddressMapper addressMapper) {
        this.addressMapper = addressMapper;
    }

    public List<Address> getByUserId(Long userId) {
        return addressMapper.selectByUserId(userId);
    }

    public Address getById(Long id) {
        return addressMapper.selectById(id);
    }

    @Transactional
    public Long save(Address address) {
        // 设默认时先清除其他默认
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            addressMapper.clearDefault(address.getUserId());
        }
        if (address.getId() != null) {
            addressMapper.updateById(address);
            return address.getId();
        }
        addressMapper.insert(address);
        return address.getId();
    }

    public void delete(Long id) {
        addressMapper.deleteById(id);
    }
}
