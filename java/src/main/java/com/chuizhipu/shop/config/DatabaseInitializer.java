package com.chuizhipu.shop.config;

import jakarta.annotation.PostConstruct;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * 启动时自动创建/修正消息相关表（私信、系统通知、商品评论），无需手动执行 SQL。
 * 兼容旧版（远程 WebSocket 版）的 t_message：检测到旧结构会自动重建为本地结构。
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
            // 旧版 t_message 含 conversation_id 列，结构与本地 REST 版不兼容 → 删掉重建
            Integer oldCol = jdbc.queryForObject(
                "SELECT COUNT(*) FROM information_schema.columns " +
                "WHERE table_schema = DATABASE() AND table_name = 't_message' AND column_name = 'conversation_id'",
                Integer.class);
            if (oldCol != null && oldCol > 0) {
                jdbc.execute("DROP TABLE t_message");
            }

            // t_product 补 is_sellable 列（旧库没有，纯展示商品需要它）
            Integer sellableCol = jdbc.queryForObject(
                "SELECT COUNT(*) FROM information_schema.columns " +
                "WHERE table_schema = DATABASE() AND table_name = 't_product' AND column_name = 'is_sellable'",
                Integer.class);
            if (sellableCol != null && sellableCol == 0) {
                jdbc.execute("ALTER TABLE t_product ADD COLUMN is_sellable TINYINT DEFAULT 1 COMMENT '是否售卖 1-售卖 0-纯展示'");
            }

            Integer deletedCol = jdbc.queryForObject(
                "SELECT COUNT(*) FROM information_schema.columns " +
                "WHERE table_schema = DATABASE() AND table_name = 't_product' AND column_name = 'is_deleted'",
                Integer.class);
            if (deletedCol != null && deletedCol == 0) {
                jdbc.execute("ALTER TABLE t_product ADD COLUMN is_deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除 0-正常 1-已删除'");
            }

            // 私信
            jdbc.execute("""
                CREATE TABLE IF NOT EXISTS t_message (
                    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
                    from_user_id BIGINT NOT NULL,
                    to_user_id   BIGINT NOT NULL,
                    content      VARCHAR(1000) NOT NULL,
                    is_read      TINYINT DEFAULT 0,
                    create_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_pair (from_user_id, to_user_id),
                    INDEX idx_to_read (to_user_id, is_read)
                ) COMMENT '私信'
            """);

            // 系统通知
            jdbc.execute("""
                CREATE TABLE IF NOT EXISTS t_notification (
                    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
                    user_id     BIGINT NOT NULL,
                    type        VARCHAR(20) NOT NULL,
                    title       VARCHAR(100) NOT NULL,
                    content     VARCHAR(500),
                    ref_id      BIGINT,
                    is_read     TINYINT DEFAULT 0,
                    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_user_read (user_id, is_read)
                ) COMMENT '系统通知'
            """);

            // 商品评论
            jdbc.execute("""
                CREATE TABLE IF NOT EXISTS t_comment (
                    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
                    product_id  BIGINT NOT NULL,
                    user_id     BIGINT NOT NULL,
                    content     VARCHAR(500) NOT NULL,
                    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_product_id (product_id)
                ) COMMENT '商品评论'
            """);

            System.out.println("✅ 消息/通知/评论表已就绪");
        } catch (Exception e) {
            System.err.println("⚠️ 消息相关表初始化失败: " + e.getMessage());
        }
    }
}
