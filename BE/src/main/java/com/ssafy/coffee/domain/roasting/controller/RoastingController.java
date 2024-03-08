package com.ssafy.coffee.domain.roasting.controller;

import com.ssafy.coffee.domain.roasting.dto.RoastingGetResponseDto;
import com.ssafy.coffee.domain.roasting.dto.RoastingPostRequestDto;
import com.ssafy.coffee.domain.roasting.dto.RoastingUpdateRequestDto;
import com.ssafy.coffee.domain.roasting.service.RoastingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@Tag(name = "roasting", description = "커피 배전도 API")
@RequestMapping("/api/roasting")
public class RoastingController {

    private final RoastingService roastingService;

    @Operation(summary = "배전도 추가", description = "새로운 배전도 정보를 추가합니다.")
    @ApiResponse(responseCode = "201", description = "배전도가 성공적으로 추가됨")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PostMapping
    public ResponseEntity<Object> addRoasting(@RequestBody RoastingPostRequestDto roastingPostRequestDto) {
        roastingService.addRoasting(roastingPostRequestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("Roasting added successfully");
    }

    @Operation(summary = "배전도 조회", description = "배전도 정보를 조회합니다.")
    @ApiResponse(responseCode = "200", description = "배전도 조회에 성공", content = @Content(schema = @Schema(implementation = RoastingGetResponseDto.class)))
    @ApiResponse(responseCode = "404", description = "제공된 roastingIndex로 배전도를 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/{roastingIndex}")
    public ResponseEntity<Object> getRoasting(@PathVariable Long roastingIndex) {
        RoastingGetResponseDto roastingGetResponseDto = roastingService.getRoasting(roastingIndex);
        return ResponseEntity.status(HttpStatus.OK).body(roastingGetResponseDto);
    }

    @Operation(summary = "배전도 리스트 조회", description = "저장된 모든 배전도의 리스트를 페이지네이션으로 조회합니다.")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @ApiResponse(responseCode = "200", description = "배전도 리스트 조회에 성공", content = @Content(array = @ArraySchema(schema = @Schema(implementation = RoastingGetResponseDto.class))))
    @GetMapping("/list")
    public ResponseEntity<List<RoastingGetResponseDto>> getAllRoastings() {
        List<RoastingGetResponseDto> roastingPage = roastingService.getAllRoastings();
        return ResponseEntity.status(HttpStatus.OK).body(roastingPage);
    }


    @Operation(summary = "배전도 수정", description = "기존 배전도 정보를 수정합니다.")
    @ApiResponse(responseCode = "204", description = "배전도가 성공적으로 업데이트됨")
    @ApiResponse(responseCode = "404", description = "제공된 roastingIndex로 배전도를 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PutMapping("/{roastingIndex}")
    public ResponseEntity<Object> updateRoasting(@PathVariable Long roastingIndex,
                                                 @Valid @RequestBody RoastingUpdateRequestDto roastingUpdateRequestDto) {
        roastingService.updateRoasting(roastingIndex, roastingUpdateRequestDto);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body("Roasting updated successfully");
    }

    @Operation(summary = "배전도 삭제", description = "배전도 정보를 삭제합니다.")
    @ApiResponse(responseCode = "204", description = "배전도가 성공적으로 삭제됨")
    @ApiResponse(responseCode = "404", description = "제공된 roastingIndex로 배전도를 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @DeleteMapping("/{roastingIndex}")
    public ResponseEntity<Object> deleteRoasting(@PathVariable Long roastingIndex) {
        roastingService.deleteRoasting(roastingIndex);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body("Roasting deleted successfully");
    }
}
