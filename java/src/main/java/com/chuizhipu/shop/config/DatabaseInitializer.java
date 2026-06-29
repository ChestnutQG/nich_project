package com.chuizhipu.shop.config;

import jakarta.annotation.PostConstruct;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * 启动时自动创建 t_message 表（如果不存在），无需手动执行 SQL
 */
@Component
public class DatabaseInitializer {

    private final JdbcTemplate jdbc;

    public DatabaseInitializer(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @PostConstruct
    public void init() {
        try {
            jdbc.execute("""
                CREATE TABLE IF NOT EXISTS t_message (
                    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
                    conversation_id  VARCHAR(64)  COMMENT '会话ID',
                    sender_id        BIGINT       NOT NULL COMMENT '发送者ID（0=系统）',
                    receiver_id      BIGINT       NOT NULL COMMENT '接收者ID',
                    content          TEXT         NOT NULL COMMENT '消息内容',
                    message_type     VARCHAR(20)  NOT NULL DEFAULT 'chat',
                    notification_type VARCHAR(30),
                    related_id       BIGINT,
                    is_read          TINYINT(1)   NOT NULL DEFAULT 0,
                    created_at       DATETIME     DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_conversation (conversation_id),
                    INDEX idx_receiver_unread (receiver_id, is_read, created_at),
                    INDEX idx_sender (sender_id)
                ) COMMENT '消息表'
            """);
            System.out.println("✅ t_message 表已就绪");
        } catch (Exception e) {
            System.err.println("⚠️ t_message 表创建失败: " + e.getMessage());
        }
    }
}
