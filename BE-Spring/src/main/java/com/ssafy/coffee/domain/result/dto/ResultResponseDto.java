package com.ssafy.coffee.domain.result.dto;

import com.ssafy.coffee.domain.recipe.entity.Recipe;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class ResultResponseDto {
    private List<String> sequenceLink;
    private int resultNormal;
    private int resultFlaw;
    private String roastingType;
    private String beanType;
    private List<Recipe> recipeList;
}
