package com.ssafy.coffee.domain.member.service;

import com.ssafy.coffee.domain.auth.dto.MemberRegistRequestDto;
import com.ssafy.coffee.domain.member.dto.MemberRequestGetDto;
import com.ssafy.coffee.domain.member.dto.MemberUpdateRequestDto;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.member.repository.MemberRepository;
import com.ssafy.coffee.domain.s3.service.S3Service;
import com.ssafy.coffee.global.constant.AuthType;
import com.ssafy.coffee.global.constant.Role;
import com.ssafy.coffee.global.exception.EntityAlreadyExistsException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MemberService {
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final S3Service s3Service;

    @Transactional
    public void registerMember(MemberRegistRequestDto memberRegistRequestDto) {
        Optional<Member> existingMember = memberRepository.findByIdAndAuthType(
                memberRegistRequestDto.getId(), AuthType.LOCAL
        );

        if (existingMember.isPresent() && !existingMember.get().isDeleted()) {
            throw new EntityAlreadyExistsException("Member with ID " + memberRegistRequestDto.getId() + " already exists.");
        }

        existingMember.ifPresent(member -> member.setDeleted(false));

        if (existingMember.isEmpty()) {
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
    }

    public MemberRequestGetDto getMember(Long memberIndex) {
        Member member = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new EntityNotFoundException("Member not found with index: " + memberIndex));
        return new MemberRequestGetDto(member);
    }

    @Transactional
    public void updateMember(Long memberIndex, MemberUpdateRequestDto memberUpdateRequestDto) {
        Member member = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new EntityNotFoundException("Member not found with index: " + memberIndex));

        if (memberUpdateRequestDto.getNickname() != null)
            member.setNickname(memberUpdateRequestDto.getNickname());
        if (memberUpdateRequestDto.getImage() != null) {
            String filePath = "member/" + memberIndex;
            String url = s3Service.uploadFile(filePath, memberUpdateRequestDto.getImage());
            member.setProfileImage(url);
        }
    }

    @Transactional
    public void deleteMember(Long memberIndex) {
        Member member = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new EntityNotFoundException("Member not found with index: " + memberIndex));
        member.setDeleted(true);
    }

    @Scheduled(cron = "0 0 1 * * *") // 테스트용 이므로 1시간
    public void permanentDeleteMemberSchedule(){

        List<Member> deleteMemberList= memberRepository.findByIsDeletedTrueAndModDateBefore(LocalDateTime.now().minusMinutes(60));
        memberRepository.deleteAll(deleteMemberList);
    }
}
