package com.ssafy.coffee.domain.board.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.Objects;
@Builder
@Getter
public class BoardLikeInfoDto {
    private boolean liked;
    private long likesCount;
    private long commentCount;
}
