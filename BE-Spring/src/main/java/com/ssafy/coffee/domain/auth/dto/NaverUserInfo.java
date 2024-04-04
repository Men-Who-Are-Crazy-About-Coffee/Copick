package com.ssafy.coffee.domain.auth.dto;

import lombok.ToString;

import java.util.Map;

@ToString
public class NaverUserInfo implements OAuth2UserInfo {
    private Map<String, Object> attributes;

    public NaverUserInfo(Map<String, Object> attributes ) {
        this.attributes = attributes;
    }

    @Override
    public String getProviderId() {
        return String.valueOf(attributes.get("id"));
    }

    @Override
    public String getProvider() {
        return "naver";
    }

    @Override
    public String getEmail() {
        return String.valueOf(attributes.get("email"));
    }

    @Override
    public String getName() {
        return String.valueOf(attributes.get("name"));
    }

    @Override
    public String getBirthYear() { return  String.valueOf(attributes.get("birthyear")); }

    @Override
    public String getNickname() { return  String.valueOf(attributes.get("nickname")); }

    @Override
    public String getProfileImageUrl() { return  String.valueOf(attributes.get("profile_image")); }
}
