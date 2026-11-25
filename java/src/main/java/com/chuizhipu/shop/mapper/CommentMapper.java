package com.chuizhipu.shop.mapper;

import com.chuizhipu.shop.entity.Comment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CommentMapper {

    /** 新增评论（自动回填 id） */
    int insert(Comment comment);

    /** 某商品的评论列表（带评论人昵称/头像，按时间倒序） */
    List<Comment> selectByProductId(@Param("productId") Long productId);
}
