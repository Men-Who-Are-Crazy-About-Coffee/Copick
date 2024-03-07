package com.ssafy.coffee.domain.comment.dto;


import lombok.Data;

import java.util.List;

@Data
public class CommentGetListResponseDto {
    List<CommentGetResponseDto> list;
    private int totalPages;
    private long totalElements;
}
