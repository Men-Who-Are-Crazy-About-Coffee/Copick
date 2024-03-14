package com.ssafy.coffee.domain.board.dto;

import com.ssafy.coffee.domain.board.entity.Board;
import com.ssafy.coffee.domain.board.entity.BoardDomain;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class BoardGetResponseDto {
    private Long index;
    private Long id;
    private String nickname;
    private List<String> images;
    private String title;
    private String content;
    private BoardDomain domain;
    private LocalDateTime regDate;

    public BoardGetResponseDto(Board board, List<String> images) {
        this.index = board.getIndex();
        this.id = board.getCreatedBy().getIndex();
        this.nickname = board.getCreatedBy().getNickname();
        this.title = board.getTitle();
        this.content = board.getContent();
        this.domain = board.getDomain();
        this.regDate = board.getRegDate();
    }
}