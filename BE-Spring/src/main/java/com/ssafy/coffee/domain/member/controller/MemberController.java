package com.ssafy.coffee.domain.member.controller;

import com.ssafy.coffee.domain.member.dto.MemberRequestGetDto;
import com.ssafy.coffee.domain.member.dto.MemberUpdateRequestDto;
import com.ssafy.coffee.domain.member.service.MemberService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequiredArgsConstructor
@Tag(name = "bean", description = "멤버 API")
@RequestMapping("/api/member")
public class MemberController {
    private final MemberService memberService;

    ////

//    @PostMapping("/register")
//    public ResponseEntity<Object> authJoin(@RequestBody MemberRegistRequestDto memberRegistRequestDto) {
//        memberService.registerMember(memberRegistRequestDto);
//        return ResponseEntity.status(HttpStatus.CREATED).body("Bean added successfully");
//    }

    ////

    @GetMapping("/{memberIndex}")
    public ResponseEntity<Object> getBean(@PathVariable Long memberIndex) {
        MemberRequestGetDto memberRequestGetDto = memberService.getMember(memberIndex);
        return ResponseEntity.status(HttpStatus.OK).body(memberRequestGetDto);
    }

    @PutMapping("/{memberIndex}")
    public ResponseEntity<Object> updateMember(@PathVariable Long memberIndex, @RequestBody MemberUpdateRequestDto memberUpdateRequestDto) {
        memberService.updateMember(memberIndex, memberUpdateRequestDto);
        return ResponseEntity.status(HttpStatus.OK).body("Member updated successfully");
    }

    @DeleteMapping("/{memberIndex}")
    public ResponseEntity<Object> deleteMember(@PathVariable Long memberIndex) {
        memberService.deleteMember(memberIndex);
        return ResponseEntity.status(HttpStatus.OK).body("Member deleted successfully");
    }


}
