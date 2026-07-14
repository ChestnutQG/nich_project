package com.chuizhipu.shop.service;

import com.chuizhipu.shop.common.EntityUtils;
import com.chuizhipu.shop.entity.Artisan;
import com.chuizhipu.shop.mapper.ArtisanMapper;
import com.chuizhipu.shop.mapper.FollowMapper;
import com.chuizhipu.shop.mapper.ProductMapper;
import com.chuizhipu.shop.vo.ArtisanVO;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ArtisanService {

    private final ArtisanMapper artisanMapper;
    private final FollowMapper followMapper;
    private final ProductMapper productMapper;

    public ArtisanService(ArtisanMapper artisanMapper, FollowMapper followMapper,
                          ProductMapper productMapper) {
        this.artisanMapper = artisanMapper;
        this.followMapper = followMapper;
        this.productMapper = productMapper;
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

    /** 更新当前用户的匠人简介；返回 false 表示该用户还没有匠人档案 */
    public boolean updateMyIntro(Long userId, String intro) {
        Artisan a = artisanMapper.selectByUserId(userId);
        if (a == null) return false;
        artisanMapper.updateIntro(a.getId(), intro);
        return true;
    }

    /** 搜索匠人 */
    public List<ArtisanVO> searchArtisans(String keyword, Long userId) {
        List<Artisan> list = artisanMapper.selectByName(keyword, 0, 20);
        return toVOList(list, userId);
    }

    private List<ArtisanVO> toVOList(List<Artisan> list, Long userId) {
        if (list.isEmpty()) return Collections.emptyList();
        return list.stream().map(a -> toVO(a, userId)).collect(Collectors.toList());
    }

    private ArtisanVO toVO(Artisan a, Long userId) {
        ArtisanVO vo = new ArtisanVO();
        vo.setId(EntityUtils.strId(a.getId()));
        vo.setUserId(EntityUtils.strId(a.getUserId()));
        vo.setName(a.getName());
        vo.setAvatar(a.getAvatar());
        vo.setTitle(a.getTitle());
        vo.setLevel(a.getLevel());
        vo.setProvince(a.getProvince());
        vo.setCity(a.getCity());
        vo.setCraftType(a.getCraftType());
        vo.setIntro(a.getIntro());
        vo.setCertificateImages(EntityUtils.parseStrList(a.getCertificateImages()));
        // 真实统计：作品数=该匠人在售作品数，粉丝数=关注该匠人的人数
        vo.setWorksCount(productMapper.selectByArtisanId(a.getId()).size());
        vo.setFollowersCount(followMapper.selectUserIdsByArtisanId(a.getId()).size());

        boolean followed = userId != null && followMapper.exists(userId, a.getId()) > 0;
        vo.setIsFollowed(followed);
        return vo;
    }
}
