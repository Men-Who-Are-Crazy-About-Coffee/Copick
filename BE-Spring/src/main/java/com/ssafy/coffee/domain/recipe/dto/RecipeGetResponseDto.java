package com.ssafy.coffee.domain.recipe.dto;

import com.ssafy.coffee.domain.recipe.entity.Recipe;
import lombok.Data;

@Data
public class RecipeGetResponseDto {
    private Long index;
    private Long beanIndex;
    private Long roastingIndex;
    private String title;
    private String content;

    public RecipeGetResponseDto(Recipe recipe) {
        this.index = recipe.getIndex();
        this.beanIndex = recipe.getBean().getIndex();
        this.roastingIndex = recipe.getRoasting().getIndex();
        this.title = recipe.getTitle();
        this.content = recipe.getContent();
    }
}
