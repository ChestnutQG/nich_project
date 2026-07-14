package com.chuizhipu.shop.entity;

import java.time.LocalDateTime;

/**
 * 订单
 */
public class Order {
    private Long id;
    private String orderNo;
    private Long userId;
    private Integer status;       // 0-待付款 1-待发货 2-待收货 3-已完成 4-退款中 5-已取消
    private Long totalAmount;     // 分
    private Long discountAmount;  // 分
    private Long freight;         // 分
    private Long payAmount;       // 分
    private String addressJson;
    private String remark;
    private LocalDateTime payTime;
    private LocalDateTime deliverTime;
    private LocalDateTime finishTime;
    private LocalDateTime cancelTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    // 关联
    private java.util.List<OrderItem> items;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getOrderNo() { return orderNo; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public Long getTotalAmount() { return totalAmount; }
    public void setTotalAmount(Long totalAmount) { this.totalAmount = totalAmount; }
    public Long getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(Long discountAmount) { this.discountAmount = discountAmount; }
    public Long getFreight() { return freight; }
    public void setFreight(Long freight) { this.freight = freight; }
    public Long getPayAmount() { return payAmount; }
    public void setPayAmount(Long payAmount) { this.payAmount = payAmount; }
    public String getAddressJson() { return addressJson; }
    public void setAddressJson(String addressJson) { this.addressJson = addressJson; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public LocalDateTime getPayTime() { return payTime; }
    public void setPayTime(LocalDateTime payTime) { this.payTime = payTime; }
    public LocalDateTime getDeliverTime() { return deliverTime; }
    public void setDeliverTime(LocalDateTime deliverTime) { this.deliverTime = deliverTime; }
    public LocalDateTime getFinishTime() { return finishTime; }
    public void setFinishTime(LocalDateTime finishTime) { this.finishTime = finishTime; }
    public LocalDateTime getCancelTime() { return cancelTime; }
    public void setCancelTime(LocalDateTime cancelTime) { this.cancelTime = cancelTime; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
    public java.util.List<OrderItem> getItems() { return items; }
    public void setItems(java.util.List<OrderItem> items) { this.items = items; }
}
