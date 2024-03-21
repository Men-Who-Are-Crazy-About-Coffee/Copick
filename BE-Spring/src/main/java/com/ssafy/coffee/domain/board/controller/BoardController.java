package com.ssafy.coffee.domain.board.controller;

import com.ssafy.coffee.domain.auth.dto.PrincipalMember;
import com.ssafy.coffee.domain.board.dto.BoardGetListResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardGetResponseDto;
import com.ssafy.coffee.domain.board.dto.BoardPostRequestDto;
import com.ssafy.coffee.domain.board.dto.BoardUpdateRequestDto;
import com.ssafy.coffee.domain.board.service.BoardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Tag(name = "board", description = "게시판 API")
@RequestMapping("/api/board")
public class BoardController {

    private final BoardService boardService;

    @Operation(summary = "게시판 작성", description = "게시판에 새로운 글을 추가합니다.")
    @ApiResponse(responseCode = "201", description = "게시판이 성공적으로 작성됨")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Object> addBoard(@ModelAttribute BoardPostRequestDto boardPostRequestDto,
                                           @AuthenticationPrincipal PrincipalMember principalMember) {
        boardService.addBoard(boardPostRequestDto, principalMember.toEntity());
        return ResponseEntity.status(HttpStatus.CREATED).body("Board added successfully");
    }

    @Operation(summary = "게시판 조회", description = "게시판을 조회합니다.")
    @ApiResponse(responseCode = "200", description = "게시판 조회에 성공", content = @Content(schema = @Schema(implementation = BoardGetResponseDto.class)))
    @ApiResponse(responseCode = "404", description = "제공된 boardIndex로 게시판을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/{boardIndex}")
    public ResponseEntity<Object> getBoard(@PathVariable Long boardIndex) {
        BoardGetResponseDto boardGetResponseDto = boardService.getBoard(boardIndex);
        return ResponseEntity.status(HttpStatus.OK).body(boardGetResponseDto);
    }

    @Operation(summary = "게시판 검색", description = "키워드, 도메인, 정렬 기준, 페이지, 페이지 크기를 이용하여 게시판을 검색합니다.")
    @ApiResponse(responseCode = "200", description = "상점 검색 성공",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = BoardGetResponseDto.class))))
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/search")
    public ResponseEntity<Object> searchBoard(
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "") String domain,
            @PageableDefault(page = 0, size = 10, sort = "index", direction = Sort.Direction.DESC) Pageable pageable) {
        BoardGetListResponseDto boardGetListResponseDto = boardService.searchBoard(keyword, domain, pageable);
        return ResponseEntity.status(HttpStatus.OK).body(boardGetListResponseDto);
    }

    @Operation(summary = "게시판 수정", description = "기존 게시판을 수정합니다.")
    @ApiResponse(responseCode = "204", description = "게시판이 성공적으로 업데이트됨")
    @ApiResponse(responseCode = "404", description = "제공된 boardIndex로 게시판을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PutMapping("/{boardIndex}")
    public ResponseEntity<Object> updateBoard(@PathVariable Long boardIndex,
                                              @ModelAttribute BoardUpdateRequestDto boardUpdateRequestDto,
                                              @AuthenticationPrincipal PrincipalMember principalMember) {
        boardService.updateBoard(boardIndex, boardUpdateRequestDto, principalMember.toEntity());
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body("Board updated successfully");
    }

    @Operation(summary = "게시판 삭제", description = "게시판을 삭제합니다.")
    @ApiResponse(responseCode = "204", description = "게시판이 성공적으로 삭제됨")
    @ApiResponse(responseCode = "404", description = "제공된 boardIndex로 게시판을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @DeleteMapping("/{boardIndex}")
    public ResponseEntity<Object> deleteBoard(@PathVariable Long boardIndex) {
        boardService.deleteBoard(boardIndex);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body("Board deleted successfully");
    }

    @PostMapping("/{boardIndex}/like")
    public ResponseEntity<Object> addLike(@PathVariable Long boardIndex, @AuthenticationPrincipal PrincipalMember principalMember) {
        boardService.addLike(boardIndex, principalMember.toEntity());
        return ResponseEntity.status(HttpStatus.OK).body("Like added successfully");
    }

    @DeleteMapping("/{boardIndex}/like")
    public ResponseEntity<Object> removeLike(@PathVariable Long boardIndex, @AuthenticationPrincipal PrincipalMember principalMember) {
        boardService.removeLike(boardIndex, principalMember.toEntity());
        return ResponseEntity.status(HttpStatus.OK).body("Like removed successfully");
    }

}
