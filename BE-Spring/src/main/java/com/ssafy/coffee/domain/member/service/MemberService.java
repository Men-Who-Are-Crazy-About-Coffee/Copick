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

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MemberService {
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void registerMember(MemberRegistRequestDto memberRegistRequestDto) {
        Optional<Member> existingMember = memberRepository.findByIdAndAuthType(
                memberRegistRequestDto.getId(), AuthType.LOCAL);

        if (existingMember.isPresent()) {
            Member member = existingMember.get();
            if (!member.isDeleted()) {
                return;
            } else {
                member.setDeleted(false);
                return;
            }
        }

        memberRepository.save(
                Member.builder()
                .id(memberRegistRequestDto.getId())
                .role(Role.USER)
                .authType(AuthType.LOCAL)
                .nickname(memberRegistRequestDto.getNickname())
                .password(passwordEncoder.encode(memberRegistRequestDto.getPassword()))
                .build()
        );
    }

    public MemberRequestGetDto getMember(Long memberIndex) {
        Member member = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new EntityNotFoundException("Member not found with index: " + memberIndex));

        return toDto(member);
    }

    @Transactional
    public void updateMember(Long memberIndex, MemberUpdateRequestDto memberUpdateRequestDto) {
        Member member = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new IllegalArgumentException("Member not found with index: " + memberIndex));

        if (memberUpdateRequestDto.getNickname() != null)
            member.setNickname(memberUpdateRequestDto.getNickname());

        if (memberUpdateRequestDto.getProfileImage() != null)
            member.setProfileImage(memberUpdateRequestDto.getProfileImage());

        if (memberUpdateRequestDto.getPassword() != null)
            member.setPassword(passwordEncoder.encode(memberUpdateRequestDto.getPassword()));

        if (memberUpdateRequestDto.getRole() != null) {
            try {
                Role role = Role.valueOf(memberUpdateRequestDto.getRole().toUpperCase());
                member.setRole(role);
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Invalid role value: " + memberUpdateRequestDto.getRole());
            }
        }
    }

    public void deleteMember(Long memberIndex) {
        Member member = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new IllegalArgumentException("Member not found with index: " + memberIndex));

        member.setDeleted(true);
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
