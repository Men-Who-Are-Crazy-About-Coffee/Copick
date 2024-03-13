package com.ssafy.coffee.domain.roasting.dto;

import lombok.Data;

@Data
public class RoastingPostRequestDto {
    private String type;
    private String content;
    private String image;
}
