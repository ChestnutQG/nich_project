package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.JuryVote;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface JuryVoteMapper {

    int insert(JuryVote vote);

    boolean existsByDisputeAndVoter(@Param("disputeId") Long disputeId, @Param("voterId") Long voterId);

    int countByDisputeId(@Param("disputeId") Long disputeId);

    int countByDisputeAndSide(@Param("disputeId") Long disputeId, @Param("voteSide") String voteSide);
}
