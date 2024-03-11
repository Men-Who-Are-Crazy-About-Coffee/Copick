package com.ssafy.coffee.domain.comment.dto;

import lombok.Data;

@Data
public class CommentUpdateRequestDto {
    private String content; // 수정될 댓글 내용
}
