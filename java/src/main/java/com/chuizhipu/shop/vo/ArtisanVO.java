package com.chuizhipu.shop.vo;

import java.util.List;

/**
 * 匠人 VO — 匹配前端 Artisan 接口
 */
public class ArtisanVO {

    private String id;
    private String name;
    private String avatar;
    private String title;
    private Integer level;
    private String province;
    private String city;
    private String craftType;
    private String intro;
    private List<String> certificateImages;
    private Integer worksCount;
    private Integer followersCount;
    private Boolean isFollowed;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
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
    public List<String> getCertificateImages() { return certificateImages; }
    public void setCertificateImages(List<String> certificateImages) { this.certificateImages = certificateImages; }
    public Integer getWorksCount() { return worksCount; }
    public void setWorksCount(Integer worksCount) { this.worksCount = worksCount; }
    public Integer getFollowersCount() { return followersCount; }
    public void setFollowersCount(Integer followersCount) { this.followersCount = followersCount; }
    public Boolean getIsFollowed() { return isFollowed; }
    public void setIsFollowed(Boolean isFollowed) { this.isFollowed = isFollowed; }
}
