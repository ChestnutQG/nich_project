package com.nonheritage.demo.repository;

import com.nonheritage.demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

/** 用户数据访问层 */
public interface UserRepository extends JpaRepository<User, Long> {
    User findByPhone(String phone);             // 按手机号查询
    User findByUsername(String username);       // 按用户名查询

    /** 查询符合条件的陪审员（信用分>=60、活跃、不在排除列表中，随机排序） */
    @Query("SELECT u FROM User u WHERE u.id NOT IN ?1 AND u.creditScore >= 60 AND u.status = 'active' ORDER BY RAND()")
    List<User> findEligibleJurors(List<Long> excludeIds);
}
