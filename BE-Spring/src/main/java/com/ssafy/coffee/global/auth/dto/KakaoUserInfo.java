package com.ssafy.coffee.global.auth.dto;

import java.util.Map;

public class KakaoUserInfo implements OAuth2UserInfo {

    private String id;
    private Map<String, Object> kakaoAccount;
    private Map<String, Object> profile;

    public KakaoUserInfo(Map<String, Object> attributes, String id ) {
        this.kakaoAccount = attributes;
        this.profile= (Map<String, Object>) (kakaoAccount.get("profile"));
        this.id = id;
    }

    @Override
    public String getProviderId() {
        return id;
    }

    @Override
    public String getProvider() {
        return "kakao";
    }

    @Override
    public String getEmail() {
        return String.valueOf(kakaoAccount.get("email"));
    }

    @Override
    public String getName() {
        return "카카오로그인사용자";
    }

    @Override
    public String getBirthYear() { return  String.valueOf(kakaoAccount.get("birthyear")); };

    @Override
    public String getNickname() { return  String.valueOf(profile.get("nickname")); }

    @Override
    public String getProfileImageUrl() { return  String.valueOf(profile.get("profile_image_url")); }
}
