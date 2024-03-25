package com.ssafy.coffee.domain.member.controller;

import com.ssafy.coffee.domain.auth.dto.PrincipalMember;
import com.ssafy.coffee.domain.member.dto.MemberRequestGetDto;
import com.ssafy.coffee.domain.member.dto.MemberUpdateRequestDto;
import com.ssafy.coffee.domain.member.service.MemberService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Tag(name = "member", description = "멤버 API")
@RequestMapping("/api/member")
public class MemberController {
    private final MemberService memberService;

    @Operation(summary = "멤버 조회", description = "멤버 정보를 조회합니다.")
    @ApiResponse(responseCode = "200", description = "멤버 조회에 성공", content = @Content(schema = @Schema(implementation = MemberRequestGetDto.class)))
    @ApiResponse(responseCode = "404", description = "제공된 memberIndex로 멤버를 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/{memberIndex}")
    public ResponseEntity<Object> getMember(@PathVariable Long memberIndex) {
        MemberRequestGetDto memberRequestGetDto = memberService.getMember(memberIndex);
        return ResponseEntity.status(HttpStatus.OK).body(memberRequestGetDto);
    }

    @Operation(summary = "내 정보 조회", description = "내 정보를 조회합니다.")
    @ApiResponse(responseCode = "200", description = "내 정보 조회에 성공", content = @Content(schema = @Schema(implementation = MemberRequestGetDto.class)))
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @GetMapping("/my")
    public ResponseEntity<Object> getMy(@AuthenticationPrincipal PrincipalMember principalMember) {
        MemberRequestGetDto memberRequestGetDto = memberService.getMember(principalMember.getIndex());
        return ResponseEntity.status(HttpStatus.OK).body(memberRequestGetDto);
    }

    @Operation(summary = "멤버 수정", description = "기존 멤버 정보를 수정합니다.")
    @ApiResponse(responseCode = "200", description = "멤버 수정에 성공")
    @ApiResponse(responseCode = "404", description = "제공된 memberIndex로 멤버를 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @PutMapping("/{memberIndex}")
    public ResponseEntity<Object> updateMember(@PathVariable Long memberIndex,
                                               @ModelAttribute MemberUpdateRequestDto memberUpdateRequestDto) {
        memberService.updateMember(memberIndex, memberUpdateRequestDto);
        return ResponseEntity.status(HttpStatus.OK).body("Member updated successfully");
    }

    @Operation(summary = "멤버 삭제", description = "멤버 정보를 삭제합니다.")
    @ApiResponse(responseCode = "200", description = "멤버 삭제에 성공")
    @ApiResponse(responseCode = "404", description = "제공된 memberIndex로 멤버를 찾을 수 없음")
    @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    @ApiResponse(responseCode = "500", description = "서버 내부 오류")
    @DeleteMapping("/{memberIndex}")
    public ResponseEntity<Object> deleteMember(@PathVariable Long memberIndex) {
        memberService.deleteMember(memberIndex);
        return ResponseEntity.status(HttpStatus.OK).body("Member deleted successfully");
    }
}