package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Follow;
import com.chuizhipu.shop.mapper.ArtisanMapper;
import com.chuizhipu.shop.mapper.FollowMapper;
import com.chuizhipu.shop.vo.ArtisanVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

/**
 * 匠人关注服务
 */
@Service
public class FollowService {

    private final FollowMapper followMapper;
    private final ArtisanMapper artisanMapper;
    private final ArtisanService artisanService;

    public FollowService(FollowMapper followMapper, ArtisanMapper artisanMapper,
                         ArtisanService artisanService) {
        this.followMapper = followMapper;
        this.artisanMapper = artisanMapper;
        this.artisanService = artisanService;
    }

    /** 关注匠人（幂等，并同步粉丝数 +1） */
    @Transactional
    public void follow(Long userId, Long artisanId) {
        if (followMapper.exists(userId, artisanId) > 0) return;
        Follow f = new Follow();
        f.setUserId(userId);
        f.setArtisanId(artisanId);
        followMapper.insert(f);
        artisanMapper.incrFollowers(artisanId, 1);
    }

    /** 取消关注（并同步粉丝数 -1） */
    @Transactional
    public void unfollow(Long userId, Long artisanId) {
        if (followMapper.exists(userId, artisanId) == 0) return;
        followMapper.delete(userId, artisanId);
        artisanMapper.incrFollowers(artisanId, -1);
    }

    /** 是否已关注 */
    public boolean isFollowed(Long userId, Long artisanId) {
        return followMapper.exists(userId, artisanId) > 0;
    }

    /** 我关注的匠人列表 */
    public List<ArtisanVO> getMyFollows(Long userId) {
        List<Long> ids = followMapper.selectArtisanIdsByUserId(userId);
        List<ArtisanVO> result = new ArrayList<>();
        for (Long aid : ids) {
            ArtisanVO vo = artisanService.getDetail(aid, userId);
            if (vo != null) result.add(vo);
        }
        return result;
    }
}
