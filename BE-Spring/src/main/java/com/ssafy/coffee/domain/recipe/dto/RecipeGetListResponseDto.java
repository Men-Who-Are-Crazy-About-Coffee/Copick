package com.ssafy.coffee.domain.recipe.dto;

import lombok.Data;

import java.util.List;

@Data
public class RecipeGetListResponseDto {
    private List<RecipeGetResponseDto> list;
    private int totalPages;
    private long totalElements;
}
