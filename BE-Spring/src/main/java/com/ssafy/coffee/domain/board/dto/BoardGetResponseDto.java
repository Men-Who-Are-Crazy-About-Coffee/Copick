package com.ssafy.coffee.domain.board.dto;
import com.ssafy.coffee.domain.board.entity.BoardDomain;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class BoardGetResponseDto {
    private Long boardIndex;
    private Long memberId;
    private String memberName;
    private List<String> images;
    private String title;
    private String content;
    private BoardDomain domain;
    private LocalDateTime regDate;
}