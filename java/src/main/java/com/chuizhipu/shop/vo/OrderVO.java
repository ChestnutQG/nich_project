package com.chuizhipu.shop.vo;

import java.util.List;

/**
 * 订单 VO — 匹配前端 Order 接口
 */
public class OrderVO {

    private String id;
    private String orderNo;
    private Integer status;
    private List<OrderItemVO> items;
    private Long totalAmount;
    private Long discountAmount;
    private Long freight;
    private Long payAmount;
    private AddressVO address;
    private Long createTime;
    private Long payTime;
    private Long deliverTime;
    private Long finishTime;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getOrderNo() { return orderNo; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public List<OrderItemVO> getItems() { return items; }
    public void setItems(List<OrderItemVO> items) { this.items = items; }
    public Long getTotalAmount() { return totalAmount; }
    public void setTotalAmount(Long totalAmount) { this.totalAmount = totalAmount; }
    public Long getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(Long discountAmount) { this.discountAmount = discountAmount; }
    public Long getFreight() { return freight; }
    public void setFreight(Long freight) { this.freight = freight; }
    public Long getPayAmount() { return payAmount; }
    public void setPayAmount(Long payAmount) { this.payAmount = payAmount; }
    public AddressVO getAddress() { return address; }
    public void setAddress(AddressVO address) { this.address = address; }
    public Long getCreateTime() { return createTime; }
    public void setCreateTime(Long createTime) { this.createTime = createTime; }
    public Long getPayTime() { return payTime; }
    public void setPayTime(Long payTime) { this.payTime = payTime; }
    public Long getDeliverTime() { return deliverTime; }
    public void setDeliverTime(Long deliverTime) { this.deliverTime = deliverTime; }
    public Long getFinishTime() { return finishTime; }
    public void setFinishTime(Long finishTime) { this.finishTime = finishTime; }
}
