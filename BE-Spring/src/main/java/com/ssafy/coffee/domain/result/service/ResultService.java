package com.ssafy.coffee.domain.result.service;

import com.ssafy.coffee.domain.bean.repository.BeanRepository;
import com.ssafy.coffee.domain.member.entity.Member;
import com.ssafy.coffee.domain.member.repository.MemberRepository;
import com.ssafy.coffee.domain.result.dto.AnalyzeResponseDto;
import com.ssafy.coffee.domain.result.entity.Result;
import com.ssafy.coffee.domain.result.entity.Sequence;
import com.ssafy.coffee.domain.result.repository.ResultRepository;
import com.ssafy.coffee.domain.result.repository.SequenceRepository;
import com.ssafy.coffee.domain.roasting.repository.RoastingRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ResultService {
    private final ResultRepository resultRepository;
    private final MemberRepository memberRepository;
    private final RoastingRepository roastingRepository;
    private final BeanRepository beanRepository;
    private final SequenceRepository sequenceRepository;
    @Value("${python.url}")
    private String pythonURL;

    @Transactional
    public Result insertEmptyResult(long memberIndex) {
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

    @Transactional
    public Result updateEmptyResult(long resultIndex) {
        Result result = resultRepository.findByIndex(resultIndex)
                .orElseThrow(() -> new EntityNotFoundException("Result not found with index: " + resultIndex));
        List<Sequence> sequenceList = sequenceRepository.findAllByResultIndex(resultIndex);
        int resultFlawCnt = 0;
        if(!sequenceList.isEmpty()) {
            for (Sequence s : sequenceList)
                resultFlawCnt += s.getFlaw();
            result.setNormalBeanCount(sequenceList.get(sequenceList.size() - 1).getNormal());
            WebClient webClient = WebClient.builder().build();
            Long response = webClient.get()
                    .uri(pythonURL+"/api/python/roasting?image_link="+sequenceList.get(sequenceList.size() - 1).getImage())
                    .retrieve().bodyToMono(Long.class).block();
            result.setRoasting(roastingRepository.findByIndex(response));
        }
        result.setFlawBeanCount(resultFlawCnt);
        return result;
    }

    public AnalyzeResponseDto getResultByRegDate(long memberIndex, LocalDateTime startDate, LocalDateTime endDate){
        Member accessMember = memberRepository.findByIndexAndIsDeletedFalse(memberIndex)
                .orElseThrow(() -> new EntityNotFoundException("Member not found with index: " + memberIndex));
        List<Result> resultList = resultRepository.findAllByMemberAndRegDateBetween(accessMember,startDate,endDate);
        if(resultList.isEmpty())
            throw new EntityNotFoundException("Result not found with date between "+startDate+"and"+endDate);
        double normalCount = 0;
        double flawCount = 0;
        double myNormalPercent = 0;
        for(Result result:resultList){
            normalCount+=result.getNormalBeanCount();
            flawCount+=result.getFlawBeanCount();
        }
        if(normalCount + flawCount > 0)
            myNormalPercent = normalCount/(normalCount+flawCount);
        myNormalPercent = Math.round(myNormalPercent*1000)/10.0;
        return AnalyzeResponseDto.builder()
                .myNormalPercent(myNormalPercent)
                .myFlawPercent((1000-myNormalPercent*10)/10.0)
                .build();
    }
}
