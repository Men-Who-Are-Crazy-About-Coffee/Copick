package com.ssafy.coffee.domain.recipe.dto;

import lombok.Data;

@Data
public class RecipeGetResponseDto {
    private Long recipeId;
    private Long beanId;
    private Long roastingId;
    private String title;
    private String content;
}
