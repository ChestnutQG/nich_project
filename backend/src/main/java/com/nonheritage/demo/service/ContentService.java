package com.nonheritage.demo.service;

import com.nonheritage.demo.dto.ContentRequest;
import com.nonheritage.demo.dto.PageResult;
import com.nonheritage.demo.entity.Content;
import com.nonheritage.demo.entity.Product;
import com.nonheritage.demo.entity.User;
import com.nonheritage.demo.repository.ContentRepository;
import com.nonheritage.demo.repository.ProductRepository;
import com.nonheritage.demo.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.*;

/** 内容服务：非遗内容的创建、查询、点赞、分页 */
@Service
public class ContentService {
    private final ContentRepository contentRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    public ContentService(ContentRepository contentRepository, UserRepository userRepository, ProductRepository productRepository) {
        this.contentRepository = contentRepository;
        this.userRepository = userRepository;
        this.productRepository = productRepository;
    }

    /** 创建内容，状态初始为reviewing @param userId 作者ID @param req 内容请求 @return 创建的内容 */
    public Content create(Long userId, ContentRequest req) {
        Content c = new Content();
        c.setUserId(userId);
        c.setTitle(req.getTitle());
        c.setDescription(req.getDescription());
        c.setType(req.getType());
        c.setMediaUrls(req.getMediaUrls());
        c.setTags(req.getTags());
        c.setIsSellable(req.getIsSellable() != null && req.getIsSellable());
        c.setStatus("reviewing");
        c.setLikeCount(0);
        c.setViewCount(0);
        return contentRepository.save(c);
    }

    /** 分页查询已通过内容 @param page 页码 @param size 每页条数 @param tag 标签筛选 @param sort 排序方式 @return 分页结果 */
    public PageResult<Map<String, Object>> list(int page, int size, String tag, String sort) {
        Sort s;
        if ("hotest".equals(sort)) s = Sort.by(Sort.Direction.DESC, "likeCount");
        else s = Sort.by(Sort.Direction.DESC, "createdAt");

        Page<Content> pg;
        if (tag != null && !tag.isEmpty())
            pg = contentRepository.findByStatusAndTagsContaining("passed", tag, PageRequest.of(page - 1, size, s));
        else
            pg = contentRepository.findByStatus("passed", PageRequest.of(page - 1, size, s));

        List<Map<String, Object>> records = new ArrayList<>();
        for (Content c : pg.getContent()) {
            records.add(toMap(c));
        }
        return new PageResult<>(records, pg.getTotalElements(), page, size);
    }

    /** 查看内容详情，增加浏览量 @param id 内容ID @param currentUserId 当前用户ID @return 内容详情含商品 */
    public Map<String, Object> detail(Long id, Long currentUserId) {
        Content c = contentRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("内容不存在"));
        if (!"passed".equals(c.getStatus()) && !c.getUserId().equals(currentUserId))
            throw new IllegalArgumentException("内容不可查看");

        c.setViewCount(c.getViewCount() + 1);
        contentRepository.save(c);

        Map<String, Object> map = toMap(c);
        List<Product> products = productRepository.findByContentId(id);
        map.put("products", products);
        return map;
    }

    /** 点赞内容，点赞数+1 @param id 内容ID */
    public void like(Long id) {
        Content c = contentRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("内容不存在"));
        c.setLikeCount(c.getLikeCount() + 1);
        contentRepository.save(c);
    }

    /** 我的发布内容 @param userId 用户ID @return 内容列表 */
    public List<Map<String, Object>> myContents(Long userId) {
        List<Content> list = contentRepository.findByUserIdOrderByCreatedAtDesc(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Content c : list) result.add(toMap(c));
        return result;
    }

    /** 将Content实体转为Map，方便前端使用 @param c 内容实体 @return 包含作者名的Map */
    private Map<String, Object> toMap(Content c) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", c.getId());
        m.put("userId", c.getUserId());
        m.put("title", c.getTitle());
        m.put("description", c.getDescription());
        m.put("type", c.getType());
        m.put("mediaUrls", c.getMediaUrls());
        m.put("tags", c.getTags());
        m.put("status", c.getStatus());
        m.put("rejectReason", c.getRejectReason());
        m.put("likeCount", c.getLikeCount());
        m.put("viewCount", c.getViewCount());
        m.put("isSellable", c.getIsSellable());
        m.put("createdAt", c.getCreatedAt());

        User u = userRepository.findById(c.getUserId()).orElse(null);
        m.put("authorName", u != null ? u.getUsername() : "未知");
        m.put("authorAvatar", u != null ? u.getAvatarUrl() : "");
        return m;
    }
}
