package com.ssafy.coffee.domain.roasting.dto;

import lombok.Data;

@Data
public class RoastingUpdateRequestDto {
    private String type;
    private String content;
    private String image;
}
