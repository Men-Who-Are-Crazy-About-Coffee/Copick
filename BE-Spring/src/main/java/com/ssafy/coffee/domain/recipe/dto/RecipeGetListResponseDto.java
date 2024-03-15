package com.ssafy.coffee.domain.recipe.dto;

import com.ssafy.coffee.domain.board.dto.BoardGetResponseDto;
import lombok.Data;

import java.util.List;

@Data
public class RecipeGetListResponseDto {
    private List<RecipeGetResponseDto> list;
    private int totalPages;
    private long totalElements;

    public  RecipeGetListResponseDto(List<RecipeGetResponseDto> list, int totalPages, long totalElements) {
        this.list = list;
        this.totalPages = totalPages;
        this.totalElements = totalElements;
    }
}
