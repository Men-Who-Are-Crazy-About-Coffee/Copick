package com.ssafy.coffee.domain.result.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class AnalyzeRequestDto {
    LocalDate startDate,endDate;
}
