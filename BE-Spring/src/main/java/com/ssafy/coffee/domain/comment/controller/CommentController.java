package com.ssafy.coffee.domain.comment.controller;

import com.ssafy.coffee.domain.auth.dto.PrincipalMember;
import com.ssafy.coffee.domain.comment.dto.CommentGetListResponseDto;
import com.ssafy.coffee.domain.comment.dto.CommentPostRequestDto;
import com.ssafy.coffee.domain.comment.dto.CommentUpdateRequestDto;
import com.ssafy.coffee.domain.comment.service.CommentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.Pageable;

@RestController
@RequiredArgsConstructor
@Tag(name = "comment", description = "댓글 API")
@RequestMapping("/api/comment")
public class CommentController {

    private final CommentService commentService;

    @Operation(summary = "댓글 작성", description = "특정 게시물에 새로운 댓글을 추가합니다.")
    @ApiResponse(responseCode = "201", description = "댓글이 성공적으로 작성됨")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PostMapping
    public ResponseEntity<Object> addComment(@RequestBody CommentPostRequestDto commentPostRequestDto,
                                             @AuthenticationPrincipal PrincipalMember principalMember) {
        commentService.addComment(commentPostRequestDto, principalMember.toEntity());
        return ResponseEntity.status(HttpStatus.CREATED).body("Comment added successfully");
    }

    @Operation(summary = "게시물별 댓글 조회", description = "특정 게시물의 모든 댓글을 조회합니다.")
    @ApiResponse(responseCode = "200", description = "댓글 조회에 성공", content = @Content(schema = @Schema(implementation = CommentGetListResponseDto.class)))
    @ApiResponse(responseCode = "404", description = "제공된 boardIndex로 댓글을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/board/{boardIndex}")
    public ResponseEntity<Object> getCommentsByBoard(@PathVariable Long boardIndex,
                                                     @PageableDefault(page = 0, size = 10, sort = "index", direction = Sort.Direction.DESC) Pageable pageable) {
        CommentGetListResponseDto commentGetListResponseDto = commentService.getCommentsByBoard(boardIndex, pageable);
        return ResponseEntity.status(HttpStatus.OK).body(commentGetListResponseDto);
    }


    @Operation(summary = "사용자별 댓글 조회", description = "특정 사용자가 작성한 모든 댓글을 조회합니다.")
    @ApiResponse(responseCode = "200", description = "댓글 조회에 성공", content = @Content(schema = @Schema(implementation = CommentGetListResponseDto.class)))
    @ApiResponse(responseCode = "404", description = "제공된 userIndex로 댓글을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/user/{userIndex}")
    public ResponseEntity<Object> getCommentsByUser(@PathVariable Long userIndex,
                                                    @PageableDefault(page = 0, size = 10, sort = "regDate", direction = Sort.Direction.DESC) Pageable pageable) {
        CommentGetListResponseDto commentGetListResponseDto = commentService.getCommentsByUser(userIndex, pageable);
        return ResponseEntity.status(HttpStatus.OK).body(commentGetListResponseDto);
    }

    @Operation(summary = "내 댓글 조회", description = "내가 작성한 모든 댓글을 조회합니다.")
    @ApiResponse(responseCode = "200", description = "댓글 조회에 성공", content = @Content(schema = @Schema(implementation = CommentGetListResponseDto.class)))
    @ApiResponse(responseCode = "404", description = "제공된 userIndex로 댓글을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/my")
    public ResponseEntity<Object> getMyComments(@AuthenticationPrincipal PrincipalMember principalMember,
                                                    @PageableDefault(page = 0, size = 10, sort = "regDate", direction = Sort.Direction.DESC) Pageable pageable) {
        CommentGetListResponseDto commentGetListResponseDto = commentService.getCommentsByUser(principalMember.getIndex(), pageable);
        return ResponseEntity.status(HttpStatus.OK).body(commentGetListResponseDto);
    }


    @Operation(summary = "댓글 수정", description = "기존 댓글을 수정합니다.")
    @ApiResponse(responseCode = "204", description = "댓글이 성공적으로 업데이트됨")
    @ApiResponse(responseCode = "404", description = "제공된 commentIndex로 댓글을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PutMapping("/{commentIndex}")
    public ResponseEntity<Object> updateComment(@PathVariable Long commentIndex,
                                                @RequestBody CommentUpdateRequestDto commentUpdateRequestDto,
                                                @AuthenticationPrincipal PrincipalMember principalMember) {
        commentService.updateComment(commentIndex, commentUpdateRequestDto, principalMember.toEntity());
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body("Comment updated successfully");
    }

    @Operation(summary = "댓글 삭제", description = "댓글을 삭제합니다.")
    @ApiResponse(responseCode = "204", description = "댓글이 성공적으로 삭제됨")
    @ApiResponse(responseCode = "404", description = "제공된 commentIndex로 댓글을 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @DeleteMapping("/{commentIndex}")
    public ResponseEntity<Object> deleteComment(@PathVariable Long commentIndex,
                                                @AuthenticationPrincipal PrincipalMember principalMember) {
        commentService.deleteComment(commentIndex, principalMember.toEntity());
        return ResponseEntity.status(HttpStatus.NO_CONTENT).body("Comment deleted successfully");
    }
}
