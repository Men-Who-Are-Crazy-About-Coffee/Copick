package com.ssafy.coffee.domain.comment.dto;


import java.util.List;

public class CommentGetListResponseDto {
    List<CommentGetResponseDto> list;
    private int totalPages;
    private long totalElements;
}
