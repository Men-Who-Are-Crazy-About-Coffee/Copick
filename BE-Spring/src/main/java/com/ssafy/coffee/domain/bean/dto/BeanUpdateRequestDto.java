package com.ssafy.coffee.domain.bean.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class BeanUpdateRequestDto {
    private String type;
    private String content;
    private MultipartFile image;
}