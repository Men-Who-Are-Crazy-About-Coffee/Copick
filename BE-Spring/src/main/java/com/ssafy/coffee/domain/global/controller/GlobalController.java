package com.ssafy.coffee.domain.global.controller;

import com.ssafy.coffee.domain.global.service.GlobalService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Tag(name = "result", description = "전역 설정 API")
@RequestMapping("/api/global")
public class GlobalController {
    private final GlobalService globalService;

    @GetMapping ("/setting")
    public ResponseEntity<Object> addBasicData() {
        globalService.addBasicData();
        return ResponseEntity.status(HttpStatus.OK).body("success");
    }
}
