package com.ssafy.coffee.domain.recipe.dto;

import lombok.Data;

@Data
public class RecipeUpdateRequestDto {
    private Long beanIndex;
    private Long roastingIndex;
    private String title;
    private String content;
}
