package com.ssafy.coffee.global.auth.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Getter
@ToString
@Builder
public class LocalLoginRequestDto {
	private String userId;
	private String password;

}
