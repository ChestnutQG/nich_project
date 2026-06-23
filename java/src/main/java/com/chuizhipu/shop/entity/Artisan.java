package com.chuizhipu.shop.entity;

import java.time.LocalDateTime;

/**
 * 匠人 / 非遗传承人
 */
public class Artisan {
    private Long id;
    private String name;
    private String avatar;
    private String title;
    private Integer level;
    private String province;
    private String city;
    private String craftType;
    private String intro;
    private String certificateImages;  // JSON 数组
    private Integer worksCount;
    private Integer followersCount;
    private LocalDateTime createTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Integer getLevel() { return level; }
    public void setLevel(Integer level) { this.level = level; }
    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getCraftType() { return craftType; }
    public void setCraftType(String craftType) { this.craftType = craftType; }
    public String getIntro() { return intro; }
    public void setIntro(String intro) { this.intro = intro; }
    public String getCertificateImages() { return certificateImages; }
    public void setCertificateImages(String certificateImages) { this.certificateImages = certificateImages; }
    public Integer getWorksCount() { return worksCount; }
    public void setWorksCount(Integer worksCount) { this.worksCount = worksCount; }
    public Integer getFollowersCount() { return followersCount; }
    public void setFollowersCount(Integer followersCount) { this.followersCount = followersCount; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}
