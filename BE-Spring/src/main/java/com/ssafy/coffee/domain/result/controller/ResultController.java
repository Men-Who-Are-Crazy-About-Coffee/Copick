package com.ssafy.coffee.domain.result.controller;

import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.domain.result.service.ResultService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "result", description = "분석 결과 API")
@RequestMapping("/api/result")
public class ResultController {
    private final ResultService resultService;

    @GetMapping("/{memberIndex}")
    public ResponseEntity<Object> getNewResultIndex(@PathVariable long memberIndex){
        Result result = resultService.insertEmptyResult(memberIndex);
        return ResponseEntity.status(HttpStatus.OK).body(result.getIndex());
    }
}
