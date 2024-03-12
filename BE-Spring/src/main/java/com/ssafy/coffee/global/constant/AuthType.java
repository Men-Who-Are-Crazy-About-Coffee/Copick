package com.ssafy.coffee.global.constant;

import lombok.Getter;

@Getter
public enum AuthType {
    GUEST(0),LOCAL(1),KAKAO(2),NAVER(3);
    private int authTypeNumber;

    private AuthType(int autyTypeNumber){
        this.authTypeNumber = autyTypeNumber;
    }

}
