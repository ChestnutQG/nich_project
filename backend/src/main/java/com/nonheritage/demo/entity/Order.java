package com.nonheritage.demo.entity;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 订单实体类 */
@Entity
@Table(name = "order_table")
public class Order {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;               // 主键
    private Long buyerId;          // 买家用户ID
    private Long sellerId;         // 卖家用户ID
    private Long productId;        // 商品ID
    private BigDecimal amount;     // 订单金额
    private String status = "pending";       // 订单状态：pending / paid / shipped / completed / cancelled
    private String afterSaleStatus = "none"; // 售后状态：none / returning / returned / refunded
    private String logisticsNo;    // 发货物流单号
    private String returnLogisticsNo; // 退货物流单号
    private LocalDateTime createdAt = LocalDateTime.now(); // 下单时间

    public Order() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getBuyerId() { return buyerId; }
    public void setBuyerId(Long buyerId) { this.buyerId = buyerId; }
    public Long getSellerId() { return sellerId; }
    public void setSellerId(Long sellerId) { this.sellerId = sellerId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAfterSaleStatus() { return afterSaleStatus; }
    public void setAfterSaleStatus(String afterSaleStatus) { this.afterSaleStatus = afterSaleStatus; }
    public String getLogisticsNo() { return logisticsNo; }
    public void setLogisticsNo(String logisticsNo) { this.logisticsNo = logisticsNo; }
    public String getReturnLogisticsNo() { return returnLogisticsNo; }
    public void setReturnLogisticsNo(String returnLogisticsNo) { this.returnLogisticsNo = returnLogisticsNo; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
