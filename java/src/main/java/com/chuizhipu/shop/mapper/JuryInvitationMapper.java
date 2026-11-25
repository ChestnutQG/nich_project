package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.JuryInvitation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface JuryInvitationMapper {

    int batchInsert(@Param("list") List<JuryInvitation> list);

    List<JuryInvitation> selectByUserId(@Param("userId") Long userId);

    List<JuryInvitation> selectByDisputeId(@Param("disputeId") Long disputeId);

    boolean existsByDisputeAndUser(@Param("disputeId") Long disputeId, @Param("userId") Long userId);

    int updateStatus(@Param("id") Long id, @Param("status") String status);

    List<Long> selectEligibleJurors(@Param("excludeIds") List<Long> excludeIds);
}
