package com.ssafy.coffee.domain.comment.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CommentGetResponseDto {
    private Long index;
    private Long boardIndex;
    private String content;
    private LocalDateTime regDate;
    private LocalDateTime modDate;
    private String createdBy;
    private String lastModifiedBy;
}
