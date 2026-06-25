package com.nonheritage.demo.repository;

import com.nonheritage.demo.entity.JuryVote;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/** 陪审投票数据访问层 */
public interface JuryVoteRepository extends JpaRepository<JuryVote, Long> {
    List<JuryVote> findByDisputeId(Long disputeId);                              // 按纠纷ID查询所有投票
    long countByDisputeId(Long disputeId);                                       // 统计某纠纷投票总数
    long countByDisputeIdAndVoteSide(Long disputeId, String voteSide);           // 统计某方得票数
    boolean existsByDisputeIdAndVoterId(Long disputeId, Long voterId);           // 判断是否已投票
}
