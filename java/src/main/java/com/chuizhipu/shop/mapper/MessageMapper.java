package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Message;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface MessageMapper {

    int insert(Message m);

    /** 两人之间的全部消息（时间升序） */
    List<Message> selectConversation(@Param("userId") Long userId,
                                     @Param("otherId") Long otherId);

    /** 我的会话列表（每个对话方最新一条 + 未读数） */
    List<Map<String, Object>> selectConversationList(@Param("userId") Long userId);

    /** 我收到的未读总数 */
    int countUnread(@Param("userId") Long userId);

    /** 把某人发给我的消息标记为已读 */
    int markConversationRead(@Param("userId") Long userId,
                             @Param("otherId") Long otherId);
}
