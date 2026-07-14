-- 迁移：新增商品评论表 t_comment
-- 在你的 MySQL 的 chuizhi_shop 库执行一次即可。

CREATE TABLE IF NOT EXISTS t_comment (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id  BIGINT NOT NULL COMMENT '商品ID',
    user_id     BIGINT NOT NULL COMMENT '评论用户ID',
    content     VARCHAR(500) NOT NULL COMMENT '评论内容',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES t_product(id),
    FOREIGN KEY (user_id)    REFERENCES t_user(id),
    INDEX idx_product_id (product_id)
) COMMENT '商品评论';
