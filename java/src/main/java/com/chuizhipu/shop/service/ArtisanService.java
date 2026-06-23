package com.chuizhipu.shop.service;

import com.chuizhipu.shop.common.EntityUtils;
import com.chuizhipu.shop.entity.Artisan;
import com.chuizhipu.shop.mapper.ArtisanMapper;
import com.chuizhipu.shop.mapper.FollowMapper;
import com.chuizhipu.shop.vo.ArtisanVO;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ArtisanService {

    private final ArtisanMapper artisanMapper;
    private final FollowMapper followMapper;

    public ArtisanService(ArtisanMapper artisanMapper, FollowMapper followMapper) {
        this.artisanMapper = artisanMapper;
        this.followMapper = followMapper;
    }

    public List<ArtisanVO> getList(String craftType, int page, int size, Long userId) {
        int offset = (page - 1) * size;
        List<Artisan> list = artisanMapper.selectList(craftType, offset, size);
        return toVOList(list, userId);
    }

    public long countList(String craftType) {
        return artisanMapper.countList(craftType);
    }

    /** 热门匠人 */
    public List<ArtisanVO> getTop(int limit, Long userId) {
        List<Artisan> list = artisanMapper.selectTop(limit);
        return toVOList(list, userId);
    }

    /** 匠人详情 */
    public ArtisanVO getDetail(Long id, Long userId) {
        Artisan artisan = artisanMapper.selectById(id);
        if (artisan == null) return null;
        return toVO(artisan, userId);
    }

    private List<ArtisanVO> toVOList(List<Artisan> list, Long userId) {
        if (list.isEmpty()) return Collections.emptyList();
        return list.stream().map(a -> toVO(a, userId)).collect(Collectors.toList());
    }

    private ArtisanVO toVO(Artisan a, Long userId) {
        ArtisanVO vo = new ArtisanVO();
        vo.setId(EntityUtils.strId(a.getId()));
        vo.setName(a.getName());
        vo.setAvatar(a.getAvatar());
        vo.setTitle(a.getTitle());
        vo.setLevel(a.getLevel());
        vo.setProvince(a.getProvince());
        vo.setCity(a.getCity());
        vo.setCraftType(a.getCraftType());
        vo.setIntro(a.getIntro());
        vo.setCertificateImages(EntityUtils.parseStrList(a.getCertificateImages()));
        vo.setWorksCount(a.getWorksCount());
        vo.setFollowersCount(a.getFollowersCount());

        boolean followed = userId != null && followMapper.exists(userId, a.getId()) > 0;
        vo.setIsFollowed(followed);
        return vo;
    }
}
