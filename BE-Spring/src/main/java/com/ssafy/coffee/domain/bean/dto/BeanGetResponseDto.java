package com.ssafy.coffee.domain.bean.dto;

import lombok.Data;

@Data
public class BeanGetResponseDto {
    private Long index;
    private String type;
    private String content;
    private String image;
}