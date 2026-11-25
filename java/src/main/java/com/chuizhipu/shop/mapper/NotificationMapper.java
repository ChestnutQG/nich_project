package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NotificationMapper {

    int insert(Notification n);

    List<Notification> selectByUserId(@Param("userId") Long userId);

    int countUnread(@Param("userId") Long userId);

    int markRead(@Param("id") Long id, @Param("userId") Long userId);

    int markAllRead(@Param("userId") Long userId);
}
