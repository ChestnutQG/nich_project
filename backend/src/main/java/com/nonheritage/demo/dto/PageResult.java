package com.nonheritage.demo.dto;

import java.util.List;

/** 分页结果封装，泛型支持任意列表类型 */
public class PageResult<T> {
    private List<T> records; // 当前页数据列表
    private long total;      // 总记录数
    private int page;        // 当前页码
    private int size;        // 每页大小

    public PageResult(List<T> records, long total, int page, int size) {
        this.records = records;
        this.total = total;
        this.page = page;
        this.size = size;
    }

    public List<T> getRecords() { return records; }
    public void setRecords(List<T> records) { this.records = records; }
    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }
    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }
    public int getSize() { return size; }
    public void setSize(int size) { this.size = size; }
}
