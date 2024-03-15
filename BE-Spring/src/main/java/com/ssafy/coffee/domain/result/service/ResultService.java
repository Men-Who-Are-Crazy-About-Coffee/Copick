package com.ssafy.coffee.domain.result.service;

import com.ssafy.coffee.domain.bean.repository.BeanRepository;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.member.repository.MemberRepository;
import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.domain.result.repository.ResultRepository;
import com.ssafy.coffee.domain.roasting.entity.Roasting;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ResultService {
    private final ResultRepository resultRepository;
    private final MemberRepository memberRepository;
    private final RoastingRepository roastingRepository;
    private final BeanRepository beanRepository;
    public Result insertEmptyResult(long memberIndex){
        Member member = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new EntityNotFoundException("Member not found with index: " + memberIndex));

        Result result = resultRepository.save(Result.builder()
                .member(member)
                .roasting(roastingRepository.findByIndex(1L))
                .bean(beanRepository.findByIndex(1L))
                .flawBeanCount(0)
                .normalBeanCount(0)
                .build());
        return result;
    }
}
