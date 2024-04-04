package com.ssafy.coffee.domain.roasting.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class RoastingPostRequestDto {
    private String type;
    private String content;
    private MultipartFile image;
}
