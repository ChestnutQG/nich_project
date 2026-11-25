package com.nonheritage.demo.repository;

import com.nonheritage.demo.entity.Content;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

/** 内容数据访问层 */
public interface ContentRepository extends JpaRepository<Content, Long> {
    Page<Content> findByStatus(String status, Pageable pageable);                          // 按状态分页查询
    Page<Content> findByStatusAndTagsContaining(String status, String tag, Pageable pageable); // 按状态+标签分页
    List<Content> findByUserIdOrderByCreatedAtDesc(Long userId);                           // 按用户ID查询，时间倒序
    List<Content> findByStatus(String status);                                             // 按状态查询全部
}
