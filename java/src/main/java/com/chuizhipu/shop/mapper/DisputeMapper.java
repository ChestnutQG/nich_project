package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Dispute;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface DisputeMapper {

    int insert(Dispute dispute);

    Dispute selectById(@Param("id") Long id);

    List<Dispute> selectByUser(@Param("userId") Long userId);

    List<Dispute> selectByStatus(@Param("status") String status);

    int updateStatus(@Param("id") Long id, @Param("status") String status);

    int updateResult(@Param("id") Long id, @Param("result") String result,
                     @Param("buyerVotes") Integer buyerVotes,
                     @Param("sellerVotes") Integer sellerVotes);

    boolean existsByOrderId(@Param("orderId") Long orderId);
}
