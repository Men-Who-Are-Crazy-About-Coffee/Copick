package com.ssafy.coffee.domain.comment.dto;

import lombok.Data;

@Data
public class CommentPostRequestDto {
    private Long boardIndex;
    private String content;
}
