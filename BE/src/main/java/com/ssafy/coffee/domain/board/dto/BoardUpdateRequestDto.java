package com.ssafy.coffee.domain.board.dto;

import lombok.Data;

@Data
public class BoardUpdateRequestDto {
    private String domain;
    private String title;
    private String content;
}
