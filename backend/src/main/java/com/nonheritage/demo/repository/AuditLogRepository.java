package com.nonheritage.demo.repository;

import com.nonheritage.demo.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

/** 审核日志数据访问层 */
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
}
