-- ==========================================
-- 锤子铺 数据库初始化脚本
-- 非遗电商平台，11 张业务表
-- ==========================================

CREATE DATABASE IF NOT EXISTS chuizhi_shop
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE chuizhi_shop;

-- 强制客户端使用 utf8mb4，避免 Windows 终端中文乱码
SET NAMES utf8mb4;

-- 先删旧表（按依赖顺序），方便重复执行
DROP TABLE IF EXISTS t_message;
DROP TABLE IF EXISTS t_jury_vote;
DROP TABLE IF EXISTS t_jury_invitation;
DROP TABLE IF EXISTS t_dispute;
DROP TABLE IF EXISTS t_follow;
DROP TABLE IF EXISTS t_favorite;
DROP TABLE IF EXISTS t_cart_item;
DROP TABLE IF EXISTS t_order_item;
DROP TABLE IF EXISTS t_order;
DROP TABLE IF EXISTS t_product_sku;
DROP TABLE IF EXISTS t_product;
DROP TABLE IF EXISTS t_address;
DROP TABLE IF EXISTS t_artisan;
DROP TABLE IF EXISTS t_category;
DROP TABLE IF EXISTS t_user;

-- ==========================================
-- 1. 用户表
-- ==========================================
CREATE TABLE t_user (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    nickname    VARCHAR(50)   COMMENT '昵称',
    avatar      VARCHAR(500)  COMMENT '头像URL',
    phone       VARCHAR(11)   NOT NULL UNIQUE COMMENT '手机号',
    password    VARCHAR(128)  COMMENT '密码哈希',
    role        VARCHAR(20)   NOT NULL DEFAULT 'user' COMMENT '角色: user|artisan|admin',
    credit_score INT          NOT NULL DEFAULT 100 COMMENT '信用分',
    status      VARCHAR(20)   NOT NULL DEFAULT 'active' COMMENT '状态: active|frozen',
    collect_count INT DEFAULT 0 COMMENT '收藏数',
    follow_count  INT DEFAULT 0 COMMENT '关注匠人数',
    order_count   INT DEFAULT 0 COMMENT '订单数',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT '用户';

-- ==========================================
-- 2. 收货地址表
-- ==========================================
CREATE TABLE t_address (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT        NOT NULL COMMENT '用户ID',
    name        VARCHAR(50)   NOT NULL COMMENT '收货人',
    phone       VARCHAR(11)   NOT NULL COMMENT '手机号',
    province    VARCHAR(20)   COMMENT '省',
    city        VARCHAR(30)   COMMENT '市',
    district    VARCHAR(30)   COMMENT '区',
    detail      VARCHAR(200)  COMMENT '详细地址',
    is_default  TINYINT DEFAULT 0 COMMENT '是否默认地址',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES t_user(id)
) COMMENT '收货地址';

-- ==========================================
-- 3. 非遗分类表（树形结构）
-- ==========================================
CREATE TABLE t_category (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50)   NOT NULL COMMENT '分类名',
    icon        VARCHAR(500)  COMMENT '图标URL',
    parent_id   BIGINT DEFAULT 0 COMMENT '父分类ID，0为一级',
    sort_order  INT    DEFAULT 0 COMMENT '排序权重',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT '非遗分类';

-- ==========================================
-- 4. 匠人 / 传承人表
-- ==========================================
CREATE TABLE t_artisan (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id           BIGINT        COMMENT '关联用户ID（登录账号）',
    name              VARCHAR(50)  NOT NULL COMMENT '姓名',
    avatar            VARCHAR(500) COMMENT '头像URL',
    title             VARCHAR(100) COMMENT '头衔（如"国家级非遗传承人"）',
    level             INT NOT NULL DEFAULT 1 COMMENT '认证等级 1-县级 2-省级 3-国家级',
    province          VARCHAR(20)  COMMENT '所在省',
    city              VARCHAR(30)  COMMENT '所在市',
    craft_type        VARCHAR(50)  COMMENT '擅长技艺',
    intro             TEXT         COMMENT '个人简介',
    certificate_images JSON        COMMENT '认证证书图片数组',
    works_count       INT DEFAULT 0 COMMENT '作品数',
    followers_count   INT DEFAULT 0 COMMENT '关注数',
    create_time       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES t_user(id)
) COMMENT '匠人/传承人';

-- ==========================================
-- 5. 商品表
-- ==========================================
CREATE TABLE t_product (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(200)  NOT NULL COMMENT '商品名称',
    description     TEXT          COMMENT '商品描述',
    category_id     BIGINT        COMMENT '分类ID',
    artisan_id      BIGINT        COMMENT '匠人ID',
    images          JSON          COMMENT '商品图片URL数组',
    video_url       VARCHAR(500)  COMMENT '视频URL（可选）',
    price           BIGINT        NOT NULL COMMENT '现价（分）',
    original_price  BIGINT        COMMENT '原价（分）',
    stock           INT NOT NULL DEFAULT 0 COMMENT '库存',
    sales           INT NOT NULL DEFAULT 0 COMMENT '销量',
    region          VARCHAR(50)   COMMENT '产地',
    craft_type      VARCHAR(50)   COMMENT '技艺类型',
    story           TEXT          COMMENT '文化故事',
    craft_process   JSON          COMMENT '制作工艺步骤 JSON',
    rating          DOUBLE DEFAULT 5.0 COMMENT '评分',
    tags            VARCHAR(500)  COMMENT '标签（逗号分隔）',
    audit_status    VARCHAR(20) DEFAULT 'pending' COMMENT '审核状态: pending-待审核 approved-已通过 rejected-已驳回',
    is_on_sale      TINYINT DEFAULT 0 COMMENT '是否上架 1-上架 0-下架',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES t_category(id),
    FOREIGN KEY (artisan_id)  REFERENCES t_artisan(id),
    INDEX idx_category (category_id),
    INDEX idx_artisan  (artisan_id),
    INDEX idx_sales    (sales),
    INDEX idx_price    (price)
) COMMENT '非遗商品';

-- ==========================================
-- 6. 商品 SKU 表
-- ==========================================
CREATE TABLE t_product_sku (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id  BIGINT        NOT NULL COMMENT '商品ID',
    name        VARCHAR(100)  NOT NULL COMMENT '规格名（如"中号·青花色"）',
    price       BIGINT        NOT NULL COMMENT '规格价格（分）',
    stock       INT NOT NULL DEFAULT 0 COMMENT '规格库存',
    image       VARCHAR(500)  COMMENT '规格图片',
    FOREIGN KEY (product_id) REFERENCES t_product(id),
    INDEX idx_product_id (product_id)
) COMMENT '商品SKU';

-- ==========================================
-- 7. 购物车表
-- ==========================================
CREATE TABLE t_cart_item (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL COMMENT '用户ID',
    product_id  BIGINT NOT NULL COMMENT '商品ID',
    sku_id      BIGINT COMMENT 'SKU ID',
    quantity    INT NOT NULL DEFAULT 1 COMMENT '数量',
    is_checked  TINYINT DEFAULT 1 COMMENT '是否勾选',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES t_user(id),
    FOREIGN KEY (product_id) REFERENCES t_product(id),
    UNIQUE KEY uk_user_sku (user_id, sku_id)
) COMMENT '购物车';

-- ==========================================
-- 8. 订单表
-- ==========================================
CREATE TABLE t_order (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_no        VARCHAR(32) NOT NULL UNIQUE COMMENT '订单号',
    user_id         BIGINT NOT NULL COMMENT '用户ID',
    status          INT NOT NULL DEFAULT 0 COMMENT '0-待付款 1-待发货 2-待收货 3-已完成 4-退款中 5-已取消',
    total_amount    BIGINT NOT NULL COMMENT '商品总额（分）',
    discount_amount BIGINT DEFAULT 0 COMMENT '优惠金额（分）',
    freight         BIGINT DEFAULT 0 COMMENT '运费（分）',
    pay_amount      BIGINT NOT NULL COMMENT '实付金额（分）',
    address_json    JSON COMMENT '收货地址快照',
    remark          VARCHAR(500) COMMENT '订单备注',
    pay_time        DATETIME COMMENT '付款时间',
    deliver_time    DATETIME COMMENT '发货时间',
    finish_time     DATETIME COMMENT '完成时间',
    cancel_time     DATETIME COMMENT '取消时间',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES t_user(id),
    INDEX idx_user_id (user_id),
    INDEX idx_status  (status),
    INDEX idx_order_no (order_no)
) COMMENT '订单';

-- ==========================================
-- 9. 订单项表
-- ==========================================
CREATE TABLE t_order_item (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id      BIGINT NOT NULL COMMENT '订单ID',
    product_id    BIGINT COMMENT '商品ID',
    product_name  VARCHAR(200) COMMENT '商品名（快照）',
    product_image VARCHAR(500) COMMENT '商品图（快照）',
    sku_id        BIGINT COMMENT 'SKU ID',
    sku_name      VARCHAR(100) COMMENT 'SKU名（快照）',
    price         BIGINT NOT NULL COMMENT '购买单价（分）',
    quantity      INT NOT NULL DEFAULT 1 COMMENT '数量',
    FOREIGN KEY (order_id) REFERENCES t_order(id),
    INDEX idx_order_id (order_id)
) COMMENT '订单项';

-- ==========================================
-- 10. 商品收藏表（用户-商品 多对多）
-- ==========================================
CREATE TABLE t_favorite (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL COMMENT '用户ID',
    product_id  BIGINT NOT NULL COMMENT '商品ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES t_user(id),
    FOREIGN KEY (product_id) REFERENCES t_product(id),
    UNIQUE KEY uk_user_product (user_id, product_id)
) COMMENT '商品收藏';

-- ==========================================
-- 11. 关注匠人表（用户-匠人 多对多）
-- ==========================================
CREATE TABLE t_follow (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT NOT NULL COMMENT '用户ID',
    artisan_id  BIGINT NOT NULL COMMENT '匠人ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES t_user(id),
    FOREIGN KEY (artisan_id) REFERENCES t_artisan(id),
    UNIQUE KEY uk_user_artisan (user_id, artisan_id)
) COMMENT '关注匠人';

-- ==========================================
-- 12. 纠纷表（小法庭维权）
-- ==========================================
CREATE TABLE t_dispute (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id        BIGINT NOT NULL COMMENT '关联订单ID',
    initiator_id    BIGINT NOT NULL COMMENT '申请人ID（买家）',
    respondent_id   BIGINT NOT NULL COMMENT '被申请人ID（卖家）',
    reason          TEXT COMMENT '维权原因',
    evidence_urls   JSON COMMENT '凭证图片URL数组',
    status          VARCHAR(20) NOT NULL DEFAULT 'negotiating' COMMENT 'negotiating|pending_jury|voting|resolved',
    result          VARCHAR(20) COMMENT 'buyer_win|seller_win',
    buyer_votes     INT DEFAULT 0 COMMENT '支持买家票数',
    seller_votes    INT DEFAULT 0 COMMENT '支持卖家票数',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES t_order(id),
    FOREIGN KEY (initiator_id) REFERENCES t_user(id),
    FOREIGN KEY (respondent_id) REFERENCES t_user(id),
    INDEX idx_status (status)
) COMMENT '纠纷/小法庭';

-- 13. 陪审邀请表
CREATE TABLE t_jury_invitation (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    dispute_id  BIGINT NOT NULL COMMENT '纠纷ID',
    user_id     BIGINT NOT NULL COMMENT '陪审员用户ID',
    status      VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending|voted',
    invite_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    vote_time   DATETIME,
    FOREIGN KEY (dispute_id) REFERENCES t_dispute(id),
    FOREIGN KEY (user_id) REFERENCES t_user(id),
    UNIQUE KEY uk_dispute_user (dispute_id, user_id)
) COMMENT '陪审邀请';

-- 14. 陪审投票表
CREATE TABLE t_jury_vote (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    dispute_id  BIGINT NOT NULL COMMENT '纠纷ID',
    voter_id    BIGINT NOT NULL COMMENT '投票人ID',
    vote_side   VARCHAR(10) NOT NULL COMMENT 'buyer|seller',
    vote_time   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dispute_id) REFERENCES t_dispute(id),
    FOREIGN KEY (voter_id) REFERENCES t_user(id),
    UNIQUE KEY uk_dispute_voter (dispute_id, voter_id)
) COMMENT '陪审投票';

-- 15. 消息表（聊天 + 通知）
CREATE TABLE t_message (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_id  VARCHAR(64)  COMMENT '会话ID（聊天消息用，格式: smallerId_largerId）',
    sender_id        BIGINT       NOT NULL COMMENT '发送者ID（0=系统）',
    receiver_id      BIGINT       NOT NULL COMMENT '接收者ID',
    content          TEXT         NOT NULL COMMENT '消息内容',
    message_type     VARCHAR(20)  NOT NULL DEFAULT 'chat' COMMENT 'chat=聊天 notification=通知',
    notification_type VARCHAR(30) COMMENT 'dispute_new|dispute_status|dispute_resolved|jury_invite|system',
    related_id       BIGINT       COMMENT '关联ID（维权ID/订单ID等）',
    is_read          TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '是否已读',
    created_at       DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_conversation (conversation_id),
    INDEX idx_receiver_unread (receiver_id, is_read, created_at),
    INDEX idx_sender (sender_id)
) COMMENT '消息（聊天+通知）';

-- ==========================================
-- 示例数据
-- ==========================================

-- 用户（密码 123456 的 MD5：e10adc3949ba59abbe56e057f20f883e）
INSERT INTO t_user (id, nickname, avatar, phone, password, role, credit_score, status, collect_count, follow_count, order_count) VALUES
(1, '爱非遗的小明', 'https://picsum.photos/seed/user01/200/200', '13800000001', 'e10adc3949ba59abbe56e057f20f883e', 'admin', 100, 'active', 12, 5, 3),
(2, '沈桂芳', 'https://picsum.photos/seed/user02/200/200', '13800000002', 'e10adc3949ba59abbe56e057f20f883e', 'artisan', 100, 'active', 8, 3, 0),
(3, '非遗守护者李华', 'https://picsum.photos/seed/user03/200/200', '13800000003', 'e10adc3949ba59abbe56e057f20f883e', 'user', 95, 'active', 5, 2, 0),
(4, '刘远山', 'https://picsum.photos/seed/user04/200/200', '13800000004', 'e10adc3949ba59abbe56e057f20f883e', 'artisan', 95, 'active', 0, 0, 0),
(5, '赵德胜', 'https://picsum.photos/seed/user05/200/200', '13800000005', 'e10adc3949ba59abbe56e057f20f883e', 'artisan', 100, 'active', 0, 0, 0),
(6, '非遗小白', 'https://picsum.photos/seed/user06/200/200', '13800000006', 'e10adc3949ba59abbe56e057f20f883e', 'user', 85, 'active', 0, 0, 0),
(7, '传统文化迷', 'https://picsum.photos/seed/user07/200/200', '13800000007', 'e10adc3949ba59abbe56e057f20f883e', 'user', 90, 'active', 0, 0, 0),
(8, '手艺爱好者', 'https://picsum.photos/seed/user08/200/200', '13800000008', 'e10adc3949ba59abbe56e057f20f883e', 'user', 80, 'active', 0, 0, 0),
(9, '国风少年', 'https://picsum.photos/seed/user09/200/200', '13800000009', 'e10adc3949ba59abbe56e057f20f883e', 'user', 95, 'active', 0, 0, 0),
(10, '文化传承者', 'https://picsum.photos/seed/user10/200/200', '13800000010', 'e10adc3949ba59abbe56e057f20f883e', 'user', 100, 'active', 0, 0, 0),
(11, '民间艺术迷', 'https://picsum.photos/seed/user11/200/200', '13800000011', 'e10adc3949ba59abbe56e057f20f883e', 'user', 88, 'active', 0, 0, 0),
(12, '匠心独运', 'https://picsum.photos/seed/user12/200/200', '13800000012', 'e10adc3949ba59abbe56e057f20f883e', 'user', 92, 'active', 0, 0, 0);

-- 分类（10 大非遗类别）
INSERT INTO t_category (id, name, icon, parent_id, sort_order) VALUES
(1,  '传统技艺',     '🎨', 0, 1),
(2,  '传统美术',     '🖌️', 0, 2),
(3,  '传统医药',     '🌿', 0, 3),
(4,  '民俗',         '🎭', 0, 4),
(5,  '传统戏剧',     '🎪', 0, 5),
(6,  '传统音乐',     '🎵', 0, 6),
(7,  '传统舞蹈',     '💃', 0, 7),
(8,  '曲艺',         '📖', 0, 8),
(9,  '传统体育游艺', '🤸', 0, 9),
(10, '民间文学',     '📚', 0, 10);

-- 匠人
INSERT INTO t_artisan (id, user_id, name, avatar, title, level, province, city, craft_type, intro, certificate_images, works_count, followers_count) VALUES
(1, 2, '沈桂芳', 'https://picsum.photos/seed/art01/200/200', '国家级非遗传承人', 3, '江苏', '苏州', '苏绣',
   '沈桂芳，1958年生于苏州镇湖刺绣世家，8岁随母学绣，从事苏绣四十余年，尤擅双面绣与仿真绣，作品多次作为国礼赠送外宾。',
   '["https://picsum.photos/seed/cert01/400/300","https://picsum.photos/seed/cert02/400/300"]', 156, 3280),
(2, 4, '刘远山', 'https://picsum.photos/seed/art02/200/200', '省级非遗传承人', 2, '江西', '景德镇', '青花瓷',
   '刘远山，1970年生于景德镇陶瓷世家，师从中国工艺美术大师王锡良，擅长青花山水。',
   '["https://picsum.photos/seed/cert03/400/300"]', 89, 1580),
(3, 5, '赵德胜', 'https://picsum.photos/seed/art03/200/200', '国家级非遗传承人', 3, '北京', '北京', '景泰蓝',
   '赵德胜，1962年生于北京，景泰蓝制作技艺国家级传承人，从事珐琅工艺四十载。',
   '["https://picsum.photos/seed/cert04/400/300"]', 72, 2100);

-- 商品（部分含视频链接，用于Feed流视频播放）
INSERT INTO t_product (id, name, description, category_id, artisan_id, images, video_url, price, original_price, stock, sales, region, craft_type, story, tags, rating, audit_status, is_on_sale) VALUES
(1, '苏绣双面绣团扇 · 蝶恋花',
   '苏州绣娘纯手工双面绣，一面蝴蝶一面花卉，丝线光泽流转，栩栩如生。紫檀木扇柄，配真丝流苏。',
   2, 1,
   '["https://picsum.photos/seed/nh01/750/750","https://picsum.photos/seed/nh02/750/750","https://picsum.photos/seed/nh03/750/750"]',
   'https://assets.mixkit.co/videos/preview/mixkit-woman-embroidering-a-fabric-with-flowers-28273-large.mp4',
   128000, 168000, 3, 127, '江苏苏州', '苏绣',
   '<p>苏绣，中国四大名绣之首，已有2500余年历史。明代正德年间，苏绣便以"精细雅洁"闻名于世。清代更是发展出双面绣技法，在同一底料上绣出正反两面完全相同的图案，成为苏绣标志性技艺。</p><p>此团扇由沈桂芳老师历时15天纯手工绣制，每平方厘米多达80针，丝线劈至1/16粗细，色彩过渡自然，蝴蝶翅膀纹理清晰可见。</p>',
   '苏绣,双面绣,团扇,国礼级', 4.9, 'approved', 1),

(2, '景德镇青花瓷茶具套装 · 山水清音',
   '景德镇非遗传承人手工拉坯，青花手绘山水纹样，一壶四杯一公道，配竹制茶盘。',
   1, 2,
   '["https://picsum.photos/seed/nh04/750/750","https://picsum.photos/seed/nh05/750/750"]',
   'https://assets.mixkit.co/videos/preview/mixkit-pottery-craftsman-making-a-ceramic-pot-39963-large.mp4',
   86000, 108000, 15, 356, '江西景德镇', '青花瓷',
   '<p>景德镇手工制瓷技艺，2006年列入第一批国家级非物质文化遗产名录。从拉坯、利坯到画坯、上釉，七十二道工序，每一道皆是千年传承。</p>',
   '青花瓷,茶具,手工,礼品', 4.8, 'approved', 1),

(3, '景泰蓝铜胎掐丝珐琅花瓶 · 花开富贵',
   '纯铜胎底，手工掐丝描金，珐琅釉料烧制，牡丹纹饰雍容华贵。',
   1, 3,
   '["https://picsum.photos/seed/nh06/750/750","https://picsum.photos/seed/nh07/750/750"]',
   NULL,
   560000, 680000, 2, 48, '北京', '景泰蓝',
   '<p>景泰蓝，又称铜胎掐丝珐琅，起源于元朝，盛行于明代景泰年间，因釉料以蓝色为主而得名。制作需经制胎、掐丝、点蓝、烧蓝、磨光、镀金等108道工序。</p>',
   '景泰蓝,珐琅,花瓶,收藏级', 4.9, 'approved', 1),

(4, '苏绣真丝围巾 · 江南烟雨',
   '100%桑蚕丝底料，苏绣手工绣制江南水墨风景，轻盈柔滑。',
   2, 1,
   '["https://picsum.photos/seed/nh08/750/750","https://picsum.photos/seed/nh09/750/750"]',
   NULL,
   36800, 46800, 25, 892, '江苏苏州', '苏绣',
   '<p>以苏州园林和江南水乡为灵感，用苏绣技艺将水墨意境呈现在真丝之上。适合日常穿搭，也是极具文化底蕴的礼品之选。</p>',
   '苏绣,真丝,围巾,日常穿搭', 4.7, 'approved', 1),

(5, '手工紫砂壶 · 仿古如意',
   '宜兴黄龙山原矿紫泥，全手工拍打成型，国家级工艺美术师作品。',
   1, 2,
   '["https://picsum.photos/seed/nh10/750/750","https://picsum.photos/seed/nh11/750/750"]',
   'https://assets.mixkit.co/videos/preview/mixkit-artisan-making-pottery-39964-large.mp4',
   198000, 258000, 5, 203, '江苏宜兴', '紫砂',
   '<p>宜兴紫砂陶制作技艺为国家级非遗。此壶选用黄龙山原矿紫泥，经风化、粉碎、练泥后，全手工拍打成型，不借助模具。壶身圆润饱满，出水利落，越养越润。</p>',
   '紫砂,茶壶,手工,收藏', 4.8, 'approved', 1),

(6, '苗族银饰手工锻造 · 凤冠',
   '贵州雷山苗族银匠纯手工锻造，传统苗族图腾凤冠造型。',
   1, 3,
   '["https://picsum.photos/seed/nh12/750/750"]',
   NULL,
   88000, 98000, 8, 156, '贵州雷山', '苗族银饰',
   '<p>苗族银饰锻制技艺是国家级非物质文化遗产。苗族银匠以传统錾刻、镂空、花丝等技法，将民族图腾和自然纹样融入银饰之中。</p>',
   '苗族银饰,凤冠,手工锻造,民族风', 4.6, 'approved', 1);

-- SKU
INSERT INTO t_product_sku (id, product_id, name, price, stock, image) VALUES
(1, 1, '团扇·蝶恋花', 128000, 3, 'https://picsum.photos/seed/nh01/750/750'),
(2, 2, '6件套·山水清音', 86000, 15, 'https://picsum.photos/seed/nh04/750/750'),
(3, 3, '6寸·花开富贵', 560000, 1, 'https://picsum.photos/seed/nh06/750/750'),
(4, 3, '8寸·花开富贵', 680000, 1, 'https://picsum.photos/seed/nh07/750/750'),
(5, 4, '标准款·江南烟雨', 36800, 15, 'https://picsum.photos/seed/nh08/750/750'),
(6, 4, '加长款·江南烟雨', 42800, 10, 'https://picsum.photos/seed/nh09/750/750'),
(7, 5, '280cc·仿古如意', 198000, 5, 'https://picsum.photos/seed/nh10/750/750'),
(8, 6, '均码·凤冠', 88000, 8, 'https://picsum.photos/seed/nh12/750/750');

-- 订单
INSERT INTO t_order (id, order_no, user_id, status, total_amount, discount_amount, freight, pay_amount, address_json, pay_time, deliver_time, create_time) VALUES
(1, '20240615142033001', 1, 2, 128000, 0, 0, 128000,
   '{"name":"张明","phone":"13912345678","province":"北京市","city":"北京市","district":"朝阳区","detail":"建国路88号SOHO现代城A座1201"}',
   '2024-06-15 14:25:00', '2024-06-16 09:30:00', '2024-06-15 14:20:33'),
(2, '20240618163512002', 1, 3, 86000, 0, 0, 86000,
   '{"name":"张明","phone":"13912345678","province":"北京市","city":"北京市","district":"朝阳区","detail":"建国路88号SOHO现代城A座1201"}',
   '2024-06-18 16:36:00', NULL, '2024-06-18 16:35:12');

-- 订单项
INSERT INTO t_order_item (id, order_id, product_id, product_name, product_image, sku_id, sku_name, price, quantity) VALUES
(1, 1, 1, '苏绣双面绣团扇 · 蝶恋花', 'https://picsum.photos/seed/nh01/200/200', 1, '团扇·蝶恋花', 128000, 1),
(2, 2, 2, '景德镇青花瓷茶具套装 · 山水清音', 'https://picsum.photos/seed/nh04/200/200', 2, '6件套·山水清音', 86000, 1);

-- 收货地址
INSERT INTO t_address (id, user_id, name, phone, province, city, district, detail, is_default) VALUES
(1, 1, '张明', '13912345678', '北京市', '北京市', '朝阳区', '建国路88号SOHO现代城A座1201', 1),
(2, 1, '张明', '13912345678', '江苏省', '苏州市', '姑苏区', '平江路128号', 0);

-- 收藏 & 关注
INSERT INTO t_favorite (user_id, product_id) VALUES (1, 1), (1, 3), (2, 2);
INSERT INTO t_follow   (user_id, artisan_id) VALUES (1, 1), (1, 2), (2, 1);
