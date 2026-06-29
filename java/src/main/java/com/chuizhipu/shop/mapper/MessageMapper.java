package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Message;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MessageMapper {

    /** 插入消息 */
    int insert(Message message);

    /** 查询某个会话的消息列表（分页） */
    List<Message> selectByConversation(@Param("conversationId") String conversationId,
                                       @Param("offset") int offset,
                                       @Param("limit") int limit);

    /** 查询用户的所有会话列表（每个会话最新一条消息） */
    List<Message> selectConversations(@Param("userId") Long userId);

    /** 查询用户的通知列表 */
    List<Message> selectNotifications(@Param("userId") Long userId,
                                      @Param("offset") int offset,
                                      @Param("limit") int limit);

    /** 查询用户未读通知数 */
    int countUnreadNotifications(@Param("userId") Long userId);

    /** 查询用户未读聊天消息数（按会话聚合） */
    int countUnreadChatMessages(@Param("userId") Long userId);

    /** 标记通知为已读 */
    int markNotificationRead(@Param("id") Long id);

    /** 标记某会话的所有聊天消息为已读 */
    int markConversationRead(@Param("conversationId") String conversationId,
                             @Param("userId") Long userId);

    /** 标记用户所有通知为已读 */
    int markAllNotificationsRead(@Param("userId") Long userId);
}
