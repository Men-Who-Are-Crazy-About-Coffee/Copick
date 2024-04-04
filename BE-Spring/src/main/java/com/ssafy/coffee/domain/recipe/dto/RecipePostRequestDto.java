package com.ssafy.coffee.domain.recipe.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class RecipePostRequestDto {
    private Long beanIndex;
    private Long roastingIndex;
    private String title;
    private String content;

    private MultipartFile[] upfiles;
}
