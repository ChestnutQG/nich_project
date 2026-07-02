USE chuizhi_shop;

ALTER TABLE t_product
    ADD COLUMN approved_at DATETIME NULL
        COMMENT '审核通过时间，用于新品流量保护'
        AFTER is_deleted;

UPDATE t_product
SET approved_at = create_time
WHERE audit_status = 'approved' AND approved_at IS NULL;

CREATE INDEX idx_product_approved_at
    ON t_product (audit_status, is_on_sale, is_deleted, approved_at);
