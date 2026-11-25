package com.nonheritage.demo.service;

import com.nonheritage.demo.entity.AuditLog;
import com.nonheritage.demo.entity.Content;
import com.nonheritage.demo.entity.User;
import com.nonheritage.demo.repository.AuditLogRepository;
import com.nonheritage.demo.repository.ContentRepository;
import com.nonheritage.demo.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.*;

/** 管理员服务：权限校验、内容审核（通过/驳回）、审核日志 */
@Service
public class AdminService {
    private final ContentRepository contentRepository;
    private final AuditLogRepository auditLogRepository;
    private final UserRepository userRepository;

    public AdminService(ContentRepository contentRepository, AuditLogRepository auditLogRepository, UserRepository userRepository) {
        this.contentRepository = contentRepository;
        this.auditLogRepository = auditLogRepository;
        this.userRepository = userRepository;
    }

    /** 校验管理员权限 @param userId 用户ID @throws IllegalArgumentException 非管理员 */
    public void checkAdmin(Long userId) {
        User u = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        if (!"admin".equals(u.getRole())) throw new IllegalArgumentException("无管理权限");
    }

    /** 获取审核内容列表 @param status 审核状态 @return 内容列表 */
    public List<Map<String, Object>> auditList(String status) {
        List<Content> list;
        if (status != null && !status.isEmpty())
            list = contentRepository.findByStatus(status);
        else
            list = contentRepository.findByStatus("reviewing");

        List<Map<String, Object>> result = new ArrayList<>();
        for (Content c : list) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", c.getId());
            m.put("title", c.getTitle());
            m.put("type", c.getType());
            m.put("mediaUrls", c.getMediaUrls());
            m.put("tags", c.getTags());
            m.put("status", c.getStatus());
            m.put("createdAt", c.getCreatedAt());

            User u = userRepository.findById(c.getUserId()).orElse(null);
            m.put("authorName", u != null ? u.getUsername() : "未知");
            result.add(m);
        }
        return result;
    }

    /** 审核通过，记录审核日志 @param contentId 内容ID @param auditorId 审核员ID */
    public void pass(Long contentId, Long auditorId) {
        Content c = contentRepository.findById(contentId).orElseThrow(() -> new IllegalArgumentException("内容不存在"));
        c.setStatus("passed");
        contentRepository.save(c);

        AuditLog log = new AuditLog();
        log.setContentId(contentId);
        log.setAuditorId(auditorId);
        log.setAction("pass");
        auditLogRepository.save(log);
    }

    /** 审核驳回，记录原因和日志 @param contentId 内容ID @param auditorId 审核员ID @param reason 驳回原因 */
    public void reject(Long contentId, Long auditorId, String reason) {
        Content c = contentRepository.findById(contentId).orElseThrow(() -> new IllegalArgumentException("内容不存在"));
        c.setStatus("rejected");
        c.setRejectReason(reason);
        contentRepository.save(c);

        AuditLog log = new AuditLog();
        log.setContentId(contentId);
        log.setAuditorId(auditorId);
        log.setAction("reject");
        log.setReason(reason);
        auditLogRepository.save(log);
    }
}
