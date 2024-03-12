package com.ssafy.coffee.domain.member.service;

import com.ssafy.coffee.domain.member.dto.MemberRegistRequestDto;
import com.ssafy.coffee.domain.member.dto.MemberRequestGetDto;
import com.ssafy.coffee.domain.member.dto.MemberUpdateRequestDto;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.member.repository.MemberRepository;
import com.ssafy.coffee.global.constant.AuthType;
import com.ssafy.coffee.global.constant.Role;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberService {
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void registerMember(MemberRegistRequestDto memberRegistRequestDto) {
        if (memberRepository.existsByIdAndAuthType(memberRegistRequestDto.getId(), AuthType.LOCAL))
            return;

        memberRepository.save(Member.builder()
                .id(memberRegistRequestDto.getId())
                .role(Role.USER)
                .authType(AuthType.LOCAL)
                .nickname(memberRegistRequestDto.getNickname())
                .password(passwordEncoder.encode(memberRegistRequestDto.getPassword()))
                .build());
    }

    public MemberRequestGetDto getMember(Long memberIndex) {
        Member member = memberRepository.findByIndex(memberIndex)
                .orElseThrow(() -> new EntityNotFoundException("Member not found with index: " + memberIndex));

        return toDto(member);
    }

    public void updateMember(Long memberIndex, MemberUpdateRequestDto memberUpdateRequestDto) {

    }

    public void deleteMember(Long memberIndex) {

    }

    public MemberRequestGetDto toDto(Member member) {
        MemberRequestGetDto dto = new MemberRequestGetDto();
        dto.setIndex(member.getIndex());
        dto.setId(member.getId());
        dto.setRole(member.getRole().name());
        dto.setNickname(member.getNickname());
        dto.setProfileImage(member.getProfileImage());
        return dto;
    }

}
