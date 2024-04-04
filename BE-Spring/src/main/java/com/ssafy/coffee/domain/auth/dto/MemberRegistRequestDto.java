package com.ssafy.coffee.domain.auth.dto;

import lombok.Data;

@Data
public class MemberRegistRequestDto {
    private String id;
    private String password;
    private String nickname;
}