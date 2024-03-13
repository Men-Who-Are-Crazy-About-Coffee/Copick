package com.ssafy.coffee.domain.recipe.dto;

import lombok.Data;

@Data
public class RecipeUpdateRequestDto {
    private Long beanId;
    private Long roastingId;
    private String title;
    private String content;
}
