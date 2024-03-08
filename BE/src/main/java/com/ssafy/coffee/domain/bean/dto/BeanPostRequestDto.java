package com.ssafy.coffee.domain.bean.dto;

import lombok.Data;

@Data
public class BeanPostRequestDto {
    private String type;
    private String content;
    private String image;
}