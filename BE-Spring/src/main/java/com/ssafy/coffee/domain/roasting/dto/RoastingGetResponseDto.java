package com.ssafy.coffee.domain.roasting.dto;

import lombok.Data;

@Data
public class RoastingGetResponseDto {
    private Long index;
    private String type;
    private String content;
    private String image;
}
