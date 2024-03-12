package com.ssafy.coffee.domain.board.dto;

import lombok.Data;
import java.util.List;

@Data
public class BoardGetListResponseDto {
    private List<BoardGetResponseDto> list;
    private int totalPages;
    private long totalElements;
}