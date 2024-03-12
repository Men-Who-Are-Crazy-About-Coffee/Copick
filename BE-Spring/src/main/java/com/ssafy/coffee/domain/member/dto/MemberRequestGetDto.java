package com.ssafy.coffee.domain.member.dto;

import lombok.Data;

@Data
public class MemberRequestGetDto {
    private Long index;
    private String id;
    private String role;
    private String nickname;
    private String profileImage;
}
