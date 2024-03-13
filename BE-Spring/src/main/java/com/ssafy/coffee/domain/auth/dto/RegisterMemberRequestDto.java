package com.ssafy.coffee.domain.auth.dto;

import com.ssafy.coffee.global.constant.AuthType;
import com.ssafy.coffee.global.constant.Role;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@ToString
public class RegisterMemberRequestDto {
    private String id;
    @Setter
    private String password;
    private String nickname;
}
