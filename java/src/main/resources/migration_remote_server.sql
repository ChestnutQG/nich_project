USE chuizhi_shop;

ALTER TABLE t_product
    ADD COLUMN is_sellable TINYINT DEFAULT 1
        COMMENT '是否售卖 1-售卖 0-纯展示';

ALTER TABLE t_product
    ADD COLUMN is_deleted TINYINT NOT NULL DEFAULT 0
        COMMENT '逻辑删除 0-正常 1-已删除';

CREATE TABLE IF NOT EXISTS t_comment (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id  BIGINT NOT NULL,
    user_id     BIGINT NOT NULL,
    content     VARCHAR(500) NOT NULL,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_id (product_id)
) COMMENT '商品评论';

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
) COMMENT '系统通知';

CREATE TABLE IF NOT EXISTS t_message (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    from_user_id BIGINT NOT NULL,
    to_user_id   BIGINT NOT NULL,
    content      VARCHAR(1000) NOT NULL,
    is_read      TINYINT DEFAULT 0,
    create_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_pair (from_user_id, to_user_id),
    INDEX idx_to_read (to_user_id, is_read)
) COMMENT '私信';
