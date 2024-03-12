package com.ssafy.coffee.domain.member.dto;

import lombok.Data;

@Data
public class MemberUpdateRequestDto {
    private String role;
    private String nickname;
    private String profileImage;
    private String password;
}
