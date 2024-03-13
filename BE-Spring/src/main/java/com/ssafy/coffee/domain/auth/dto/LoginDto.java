package com.ssafy.coffee.domain.auth.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Getter
@ToString
@Builder
public class LoginDto {
	private String id;
	private String password;

}
