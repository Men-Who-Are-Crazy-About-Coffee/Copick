package com.ssafy.coffee.domain.bean.dto;

import com.ssafy.coffee.domain.bean.entity.Bean;
import lombok.Data;

@Data
public class BeanGetResponseDto {
    private Long index;
    private String type;
    private String content;
    private String image;

    public BeanGetResponseDto(Bean bean) {
        this.index = bean.getIndex();
        this.type = bean.getContent();
        this.content = bean.getContent();
        this.image = bean.getImage();
    }
}