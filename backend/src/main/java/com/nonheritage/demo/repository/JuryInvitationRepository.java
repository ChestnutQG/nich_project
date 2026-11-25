package com.nonheritage.demo.repository;

import com.nonheritage.demo.entity.JuryInvitation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

/** 陪审邀请数据访问层 */
public interface JuryInvitationRepository extends JpaRepository<JuryInvitation, Long> {
    List<JuryInvitation> findByUserIdOrderByInviteTimeDesc(Long userId);    // 按用户ID查询邀请，时间倒序
    List<JuryInvitation> findByDisputeId(Long disputeId);                  // 按纠纷ID查询
    boolean existsByDisputeIdAndUserId(Long disputeId, Long userId);       // 判断是否已有邀请
    List<JuryInvitation> findByDisputeIdAndStatus(Long disputeId, String status); // 按纠纷ID+状态查询
}
