package com.ssafy.coffee.domain.member.dto;

import lombok.Data;

@Data
public class MemberRegistRequestDto {
    private String id;
    private String password;
    private String nickname;
}