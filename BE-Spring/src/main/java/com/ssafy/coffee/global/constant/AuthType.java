package com.ssafy.coffee.global.constant;

import lombok.Getter;

@Getter
public enum AuthType {
    LOCAL(1),KAKAO(2),NAVER(3),GUEST(4);
    private int authTypeNumber;

    private AuthType(int autyTypeNumber){
        this.authTypeNumber = autyTypeNumber;
    }

}
