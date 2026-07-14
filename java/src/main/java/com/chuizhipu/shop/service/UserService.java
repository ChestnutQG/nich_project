package com.chuizhipu.shop.service;

import com.chuizhipu.shop.entity.Artisan;
import com.chuizhipu.shop.entity.User;
import com.chuizhipu.shop.mapper.ArtisanMapper;
import com.chuizhipu.shop.mapper.FavoriteMapper;
import com.chuizhipu.shop.mapper.FollowMapper;
import com.chuizhipu.shop.mapper.OrderMapper;
import com.chuizhipu.shop.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class UserService {

    private final UserMapper userMapper;
    private final FavoriteMapper favoriteMapper;
    private final FollowMapper followMapper;
    private final OrderMapper orderMapper;
    private final ArtisanMapper artisanMapper;

    public UserService(UserMapper userMapper, FavoriteMapper favoriteMapper,
                       FollowMapper followMapper, OrderMapper orderMapper,
                       ArtisanMapper artisanMapper) {
        this.userMapper = userMapper;
        this.favoriteMapper = favoriteMapper;
        this.followMapper = followMapper;
        this.orderMapper = orderMapper;
        this.artisanMapper = artisanMapper;
    }

    /** 用户公开主页：基本资料 + 是否匠人（含匠人信息/关注状态） */
    public Map<String, Object> getPublicProfile(Long targetId, Long currentUserId) {
        User u = userMapper.selectById(targetId);
        if (u == null) return null;
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", u.getId().toString());
        m.put("nickname", u.getNickname() != null ? u.getNickname() : "用户");
        m.put("avatar", u.getAvatar() != null ? u.getAvatar() : "");
        m.put("role", u.getRole() != null ? u.getRole() : "user");

        Artisan a = artisanMapper.selectByUserId(targetId);
        boolean isArtisan = a != null;
        m.put("isArtisan", isArtisan);
        if (isArtisan) {
            m.put("artisanId", a.getId().toString());
            m.put("title", a.getTitle() != null ? a.getTitle() : "");
            m.put("intro", a.getIntro() != null ? a.getIntro() : "");
            m.put("craftType", a.getCraftType() != null ? a.getCraftType() : "");
            m.put("level", a.getLevel() != null ? a.getLevel() : 1);
            m.put("province", a.getProvince() != null ? a.getProvince() : "");
            m.put("city", a.getCity() != null ? a.getCity() : "");
            // 真实粉丝数：统计 t_follow 中关注该匠人的人数
            int realFollowers = followMapper.selectUserIdsByArtisanId(a.getId()).size();
            m.put("worksCount", a.getWorksCount() != null ? a.getWorksCount() : 0);
            m.put("followersCount", realFollowers);
            boolean followed = currentUserId != null && followMapper.exists(currentUserId, a.getId()) > 0;
            m.put("isFollowed", followed);
        }
        return m;
    }

    public User getById(Long id) {
        User user = userMapper.selectById(id);
        if (user != null) fillCounts(user);
        return user;
    }

    public User getByPhone(String phone) {
        User user = userMapper.selectByPhone(phone);
        if (user != null) fillCounts(user);
        return user;
    }

    /** 用真实表数据覆盖 collectCount / followCount / orderCount */
    private void fillCounts(User user) {
        Long userId = user.getId();
        user.setCollectCount(favoriteMapper.countByUserId(userId));
        user.setFollowCount(followMapper.countByUserId(userId));
        user.setOrderCount(orderMapper.countByUserId(userId));
    }

    /** 注册 — 密码 MD5 哈希 */
    public Long register(User user) {
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(DigestUtils.md5DigestAsHex(user.getPassword().getBytes(StandardCharsets.UTF_8)));
        }
        if (user.getRole() == null) user.setRole("user");
        if (user.getCreditScore() == null) user.setCreditScore(100);
        if (user.getStatus() == null) user.setStatus("active");
        userMapper.insert(user);
        return user.getId();
    }

    /** 登录验证 — 返回用户或 null */
    public User login(String phone, String password) {
        User user = userMapper.selectByPhone(phone);
        if (user == null) return null;
        if ("frozen".equals(user.getStatus())) return null;
        String hashed = DigestUtils.md5DigestAsHex(password.getBytes(StandardCharsets.UTF_8));
        if (!hashed.equals(user.getPassword())) return null;
        fillCounts(user);
        return user;
    }

    /** 手机号一键登录/注册（无密码） */
    public User phoneLogin(String phone) {
        User user = userMapper.selectByPhone(phone);
        if (user == null) {
            user = new User();
            user.setPhone(phone);
            user.setNickname("非遗爱好者");
            user.setRole("user");
            user.setCreditScore(100);
            user.setStatus("active");
            userMapper.insert(user);
            return user;
        }
        fillCounts(user);
        return user;
    }

    public void updateProfile(User user) {
        userMapper.updateById(user);
    }

    /** 按昵称/手机号搜索用户 */
    public List<User> searchUsers(String keyword) {
        return userMapper.selectByKeyword(keyword);
    }
}
