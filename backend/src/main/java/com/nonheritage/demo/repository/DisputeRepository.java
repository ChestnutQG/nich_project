package com.nonheritage.demo.repository;

import com.nonheritage.demo.entity.Dispute;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/** 纠纷数据访问层 */
public interface DisputeRepository extends JpaRepository<Dispute, Long> {
    List<Dispute> findByInitiatorIdOrRespondentIdOrderByCreatedAtDesc(Long initiatorId, Long respondentId); // 按发起方或被诉方查询
    List<Dispute> findByStatus(String status); // 按状态查询
}
