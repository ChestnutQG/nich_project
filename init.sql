-- ============================================================
-- 国风非遗文化宣传与交易平台 - 数据库初始化脚本
-- MySQL 8.0+, InnoDB, utf8mb4
-- ============================================================

DROP DATABASE IF EXISTS nonheritage_db;
CREATE DATABASE nonheritage_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE nonheritage_db;
SET NAMES utf8mb4;

-- ============================================================
-- 1. 用户表
-- ============================================================
CREATE TABLE user (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(64)  NOT NULL,
    password    VARCHAR(128) NOT NULL,
    phone       VARCHAR(20),
    avatar_url  VARCHAR(512),
    role        VARCHAR(16)  NOT NULL DEFAULT 'user' COMMENT 'user/admin',
    credit_score INT         NOT NULL DEFAULT 100,
    status      VARCHAR(16)  NOT NULL DEFAULT 'active' COMMENT 'active/frozen',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. 内容表
-- ============================================================
CREATE TABLE content (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT       NOT NULL,
    title         VARCHAR(256) NOT NULL,
    description   TEXT,
    type          VARCHAR(16)  NOT NULL COMMENT 'image/video',
    media_urls    TEXT         COMMENT 'JSON数组',
    tags          VARCHAR(512),
    status        VARCHAR(16)  NOT NULL DEFAULT 'draft' COMMENT 'draft/reviewing/passed/rejected',
    reject_reason VARCHAR(512),
    like_count    INT          NOT NULL DEFAULT 0,
    view_count    INT          NOT NULL DEFAULT 0,
    is_sellable   TINYINT(1)   NOT NULL DEFAULT 0,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. 商品表
-- ============================================================
CREATE TABLE product (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    content_id  BIGINT         NOT NULL,
    seller_id   BIGINT         NOT NULL,
    name        VARCHAR(256)   NOT NULL,
    price       DECIMAL(10,2)  NOT NULL,
    stock       INT            NOT NULL DEFAULT 0,
    description TEXT,
    images      TEXT           COMMENT 'JSON数组',
    status      VARCHAR(16)    NOT NULL DEFAULT 'on_sale' COMMENT 'on_sale/off_sale',
    created_at  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (content_id) REFERENCES content(id),
    FOREIGN KEY (seller_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. 订单表
-- ============================================================
CREATE TABLE order_table (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    buyer_id          BIGINT        NOT NULL,
    seller_id         BIGINT        NOT NULL,
    product_id        BIGINT        NOT NULL,
    amount            DECIMAL(10,2) NOT NULL,
    status            VARCHAR(16)   NOT NULL DEFAULT 'pending' COMMENT 'pending/paid/shipped/received/completed',
    after_sale_status VARCHAR(16)   NOT NULL DEFAULT 'none' COMMENT 'none/disputing/returning/refunded',
    logistics_no      VARCHAR(64),
    return_logistics_no VARCHAR(64),
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id)  REFERENCES user(id),
    FOREIGN KEY (seller_id) REFERENCES user(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. 纠纷表（小法庭）
-- ============================================================
CREATE TABLE dispute (
    id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id           BIGINT       NOT NULL,
    initiator_id       BIGINT       NOT NULL COMMENT '发起人=买家',
    respondent_id      BIGINT       NOT NULL COMMENT '被诉人=卖家',
    reason             TEXT         NOT NULL,
    evidence_urls      TEXT         COMMENT 'JSON数组',
    status             VARCHAR(16)  NOT NULL DEFAULT 'negotiating' COMMENT 'negotiating/pending_jury/voting/resolved',
    result             VARCHAR(16)  COMMENT 'buyer_win/seller_win',
    buyer_support_rate DECIMAL(5,2),
    created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)      REFERENCES order_table(id),
    FOREIGN KEY (initiator_id)  REFERENCES user(id),
    FOREIGN KEY (respondent_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. 陪审邀请表
-- ============================================================
CREATE TABLE jury_invitation (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    dispute_id BIGINT      NOT NULL,
    user_id    BIGINT      NOT NULL,
    status     VARCHAR(16) NOT NULL DEFAULT 'pending' COMMENT 'pending/accepted/voted/expired',
    invite_time DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    vote_time  DATETIME,
    FOREIGN KEY (dispute_id) REFERENCES dispute(id),
    FOREIGN KEY (user_id)    REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. 陪审投票表
-- ============================================================
CREATE TABLE jury_vote (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    dispute_id BIGINT      NOT NULL,
    voter_id   BIGINT      NOT NULL,
    vote_side  VARCHAR(16) NOT NULL COMMENT 'buyer/seller',
    vote_time  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dispute_id) REFERENCES dispute(id),
    FOREIGN KEY (voter_id)   REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. 审核日志表
-- ============================================================
CREATE TABLE audit_log (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    content_id BIGINT      NOT NULL,
    auditor_id BIGINT      NOT NULL,
    action     VARCHAR(16) NOT NULL COMMENT 'pass/reject',
    reason     VARCHAR(512),
    created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (content_id) REFERENCES content(id),
    FOREIGN KEY (auditor_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 模拟数据
-- ============================================================

-- 5个用户（密码均为 123456 的简单哈希模拟，实际项目请用BCrypt）
INSERT INTO user (id, username, password, phone, avatar_url, role, credit_score, status) VALUES
(1, 'admin',    '123456', '13800000001', 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin',   'admin', 100, 'active'),
(2, 'zhangsan', '123456', '13800000002', 'https://api.dicebear.com/7.x/avataaars/svg?seed=zhangsan', 'user',  95,  'active'),
(3, 'lisi',     '123456', '13800000003', 'https://api.dicebear.com/7.x/avataaars/svg?seed=lisi',     'user',  88,  'active'),
(4, 'wangwu',   '123456', '13800000004', 'https://api.dicebear.com/7.x/avataaars/svg?seed=wangwu',   'user',  72,  'active'),
(5, 'zhaoliu',  '123456', '13800000005', 'https://api.dicebear.com/7.x/avataaars/svg?seed=zhaoliu',  'user',  60,  'active');

-- 5条已通过审核的国风内容
INSERT INTO content (id, user_id, title, description, type, media_urls, tags, status, like_count, view_count, is_sellable, created_at) VALUES
(1, 2, '苏绣双面绣《荷塘月色》',
 '苏州双面绣，一面荷花一面月光，手工精制，丝线细腻，展现了苏绣非遗技艺的精髓。',
 'image',
 '["https://picsum.photos/seed/suxiu1/800/600","https://picsum.photos/seed/suxiu2/800/600","https://picsum.photos/seed/suxiu3/800/600"]',
 '苏绣,非遗,手工', 'passed', 128, 2300, 1, '2024-01-15 10:00:00'),

(2, 3, '景德镇青花瓷制作全过程',
 '从揉泥到拉坯，从绘画到上釉，完整记录景德镇青花瓷制作流程。',
 'video',
 '["https://picsum.photos/seed/qinghua1/800/600","https://picsum.photos/seed/qinghua2/800/600"]',
 '陶瓷,青花瓷,景德镇', 'passed', 256, 5100, 1, '2024-02-20 14:30:00'),

(3, 2, '苗族银饰锻造技艺',
 '贵州黔东南老银匠亲手打造的苗族银饰，每一件都是独一无二的艺术品。',
 'image',
 '["https://picsum.photos/seed/miaoyin1/800/600","https://picsum.photos/seed/miaoyin2/800/600","https://picsum.photos/seed/miaoyin3/800/600","https://picsum.photos/seed/miaoyin4/800/600"]',
 '苗族,银饰,锻造', 'passed', 89, 1800, 1, '2024-03-10 09:00:00'),

(4, 4, '皮影戏《西游记》片段',
 '陕西皮影戏传承人表演西游记经典片段，光影交错间展现千年艺术魅力。',
 'video',
 '["https://picsum.photos/seed/piying1/800/600","https://picsum.photos/seed/piying2/800/600"]',
 '皮影戏,西游记,陕西', 'passed', 312, 7800, 0, '2024-04-05 16:00:00'),

(5, 5, '蜀锦织造—寸锦寸金',
 '成都蜀锦织造技艺展示，经纬之间编织出华丽的图纹，每寸皆是匠心。',
 'image',
 '["https://picsum.photos/seed/shujin1/800/600","https://picsum.photos/seed/shujin2/800/600","https://picsum.photos/seed/shujin3/800/600"]',
 '蜀锦,织造,成都', 'passed', 201, 4200, 0, '2024-05-18 11:00:00');

-- 3个商品
INSERT INTO product (id, content_id, seller_id, name, price, stock, description, images, status) VALUES
(1, 1, 2, '苏绣双面绣《荷塘月色》手作', 1280.00, 3,
 '纯手工苏绣双面绣摆件，含实木框架，尺寸30x30cm。',
 '["https://picsum.photos/seed/suxiu_p1/600/600","https://picsum.photos/seed/suxiu_p2/600/600"]',
 'on_sale'),

(2, 2, 3, '景德镇手绘青花瓷杯', 380.00, 10,
 '景德镇高岭土手工拉坯，钴料手绘缠枝莲纹，容量200ml。',
 '["https://picsum.photos/seed/qinghua_p1/600/600","https://picsum.photos/seed/qinghua_p2/600/600"]',
 'on_sale'),

(3, 3, 2, '苗银手工錾刻手镯', 680.00, 5,
 '贵州雷山苗族银匠纯银手工錾刻，传统蝴蝶纹样，开口可调节。',
 '["https://picsum.photos/seed/miaoyin_p1/600/600","https://picsum.photos/seed/miaoyin_p2/600/600"]',
 'on_sale');

-- 2笔订单（received/completed）
INSERT INTO order_table (id, buyer_id, seller_id, product_id, amount, status, after_sale_status, logistics_no, created_at) VALUES
(1, 4, 2, 1, 1280.00, 'received', 'none',   'SF1234567890', '2024-06-01 10:00:00'),
(2, 3, 2, 3, 680.00,  'completed','none',   'SF1234567891', '2024-06-10 14:00:00');
