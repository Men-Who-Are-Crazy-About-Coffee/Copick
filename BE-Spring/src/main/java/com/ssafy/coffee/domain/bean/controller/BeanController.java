package com.ssafy.coffee.domain.bean.controller;

import com.ssafy.coffee.domain.bean.dto.BeanGetResponseDto;
import com.ssafy.coffee.domain.bean.dto.BeanPostRequestDto;
import com.ssafy.coffee.domain.bean.dto.BeanUpdateRequestDto;
import com.ssafy.coffee.domain.bean.service.BeanService;
import com.ssafy.coffee.domain.auth.dto.PrincipalMember;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@Tag(name = "bean", description = "커피콩 API")
@RequestMapping("/api/bean")
public class BeanController {

    private final BeanService beanService;

    @Operation(summary = "커피콩 추가", description = "새로운 커피콩 정보를 추가합니다.")
    @ApiResponse(responseCode = "201", description = "커피콩이 성공적으로 추가됨")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Object> addBean(@ModelAttribute BeanPostRequestDto beanPostRequestDto) {
        beanService.addBean(beanPostRequestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("Bean added successfully");
    }

    @Operation(summary = "커피콩 조회", description = "커피콩 정보를 조회합니다.")
    @ApiResponse(responseCode = "200", description = "커피콩 조회에 성공", content = @Content(schema = @Schema(implementation = BeanGetResponseDto.class)))
    @ApiResponse(responseCode = "404", description = "제공된 beanIndex로 커피콩을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/{beanIndex}")
    public ResponseEntity<Object> getBean(@PathVariable Long beanIndex) {
        BeanGetResponseDto beanGetResponseDto = beanService.getBean(beanIndex);
        return ResponseEntity.status(HttpStatus.OK).body(beanGetResponseDto);
    }

    @Operation(summary = "모든 커피콩 조회", description = "저장된 모든 커피콩의 정보를 조회합니다.")
    @ApiResponse(responseCode = "200", description = "커피콩 리스트 조회에 성공", content = @Content(array = @ArraySchema(schema = @Schema(implementation = BeanGetResponseDto.class))))
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/list")
    public ResponseEntity<Object> getAllBeans() {
        List<BeanGetResponseDto> beans = beanService.getAllBeans();
        return ResponseEntity.status(HttpStatus.OK).body(beans);
    }

    @Operation(summary = "커피콩 수정", description = "기존 커피콩 정보를 수정합니다.")
    @ApiResponse(responseCode = "204", description = "커피콩이 성공적으로 업데이트됨")
    @ApiResponse(responseCode = "404", description = "제공된 beanIndex로 커피콩을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PutMapping(path = "/{beanIndex}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Object> updateBean(@PathVariable Long beanIndex,
                                             @ModelAttribute BeanUpdateRequestDto beanUpdateRequestDto) {
        beanService.updateBean(beanIndex, beanUpdateRequestDto);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build(); // 본문을 비워 응답
    }

    @Operation(summary = "커피콩 삭제", description = "커피콩 정보를 삭제합니다.")
    @ApiResponse(responseCode = "204", description = "커피콩이 성공적으로 삭제됨")
    @ApiResponse(responseCode = "404", description = "제공된 beanIndex로 커피콩을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @DeleteMapping("/{beanIndex}")
    public ResponseEntity<Object> deleteBean(@PathVariable Long beanIndex) {
        beanService.deleteBean(beanIndex);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body("Bean deleted successfully");
    }
}
