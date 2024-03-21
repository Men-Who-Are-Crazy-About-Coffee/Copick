package com.ssafy.coffee.domain.board.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class BoardUpdateRequestDto {
    private String domain;
    private String title;
    private String content;
    private MultipartFile[] images;
}
