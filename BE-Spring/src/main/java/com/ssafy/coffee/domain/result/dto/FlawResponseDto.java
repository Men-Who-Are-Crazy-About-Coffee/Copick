package com.ssafy.coffee.domain.result.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class FlawResponseDto {
    private LocalDateTime regDate; // 등록 일시
    private String image;
}
