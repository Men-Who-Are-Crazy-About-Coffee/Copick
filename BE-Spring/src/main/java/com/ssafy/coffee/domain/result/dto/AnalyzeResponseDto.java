package com.ssafy.coffee.domain.result.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AnalyzeResponseDto {
    Double myNormalPercent,myFlawPercent,totalNormalPercent;
}
