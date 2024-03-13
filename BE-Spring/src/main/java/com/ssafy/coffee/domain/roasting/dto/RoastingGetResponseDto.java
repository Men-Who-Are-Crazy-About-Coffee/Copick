package com.ssafy.coffee.domain.roasting.dto;

import com.ssafy.coffee.domain.roasting.entity.Roasting;
import lombok.Data;

@Data
public class RoastingGetResponseDto {
    private Long index;
    private String type;
    private String content;
    private String image;

    public RoastingGetResponseDto(Roasting roasting) {
        this.index = roasting.getIndex();
        this.type = roasting.getContent();
        this.content = roasting.getContent();
        this.image = roasting.getImage();
    }
}
