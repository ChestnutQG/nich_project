-- 迁移：消息通知 + 私信
-- 对 chuizhi_shop 库执行一次即可。

-- 系统通知（单向：系统 -> 用户）
CREATE TABLE IF NOT EXISTS t_notification (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL COMMENT '接收用户ID',
    type        VARCHAR(20) NOT NULL COMMENT '类型 order/follow/comment/dispute/system',
    title       VARCHAR(100) NOT NULL COMMENT '标题',
    content     VARCHAR(500) COMMENT '内容',
    ref_id      BIGINT COMMENT '关联业务ID（订单/商品/纠纷等）',
    is_read     TINYINT DEFAULT 0 COMMENT '0未读 1已读',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES t_user(id),
    INDEX idx_user_read (user_id, is_read)
) COMMENT '系统通知';

-- 私信（用户 <-> 用户）
CREATE TABLE IF NOT EXISTS t_message (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    from_user_id BIGINT NOT NULL COMMENT '发送者',
    to_user_id   BIGINT NOT NULL COMMENT '接收者',
    content      VARCHAR(1000) NOT NULL COMMENT '内容',
    is_read      TINYINT DEFAULT 0 COMMENT '接收者是否已读 0未读 1已读',
    create_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_user_id) REFERENCES t_user(id),
    FOREIGN KEY (to_user_id)   REFERENCES t_user(id),
    INDEX idx_pair (from_user_id, to_user_id),
    INDEX idx_to_read (to_user_id, is_read)
) COMMENT '私信';
