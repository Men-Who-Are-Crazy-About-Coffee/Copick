package com.ssafy.coffee.domain.member.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class MemberUpdateRequestDto {
    private String nickname;
    private MultipartFile image;
}
