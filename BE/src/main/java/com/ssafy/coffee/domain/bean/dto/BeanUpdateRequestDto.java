package com.ssafy.coffee.domain.bean.dto;

import lombok.Data;

@Data
public class BeanUpdateRequestDto {
    private String type;
    private String content;
    private String image;
}